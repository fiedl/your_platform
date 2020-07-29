class AccommodationSepaDebitsController < ApplicationController

  expose :corporation
  expose :institution, -> { corporation.accommodations_institution }
  expose :bank_account, -> { institution.bank_account }

  expose :rooms, -> { corporation.rooms }
  expose :rooms_json, -> { rooms.collect { |room|
    room.as_json.merge({
      occupant: (room.occupant.as_json.merge({
        bank_account: (room.occupant.bank_account.as_json.merge({
          account_holder: room.occupant.bank_account.account_holder,
          iban: room.occupant.bank_account.iban,
          bic: room.occupant.bank_account.bic,
        }) if room.occupant.bank_account),
        mandate_id: mandate_id_for_user(room.occupant),
        mandate_id_setting: mandate_id_setting(room.occupant),
        mandate_date_of_signature: mandate_date_of_signature_for_user(room.occupant),
        mandate_date_setting: mandate_date_setting(room.occupant),
      }) if room.occupant)
    })
  }.to_json }

  def new
    authorize! :create_accommodation_sepa_debit, corporation

    set_current_title "Miet-Einzug Wohnheim #{corporation.title}"
    set_current_navable institution
    set_current_tab :contacts
  end

  expose :subject, -> { params[:subject] }
  expose :creditor_identifier, -> { params[:creditor_identifier] || institution.settings.creditor_identifier }

  def create
    authorize! :create_accommodation_sepa_debit, corporation

    institution.settings.creditor_identifier = creditor_identifier

    # https://github.com/salesking/sepa_king
    #
    sdd = SEPA::DirectDebit.new(
      # Name of the initiating party and creditor, in German: "Auftraggeber"
      # String, max. 70 char
      name: bank_account.account_holder,

      # OPTIONAL: Business Identifier Code (SWIFT-Code) of the creditor
      # String, 8 or 11 char
      bic: bank_account.bic,

      # International Bank Account Number of the creditor
      # String, max. 34 chars
      iban: bank_account.iban.gsub(" ", ""),

      # Creditor Identifier, in German: Gläubiger-Identifikationsnummer
      # String, max. 35 chars
      creditor_identifier: creditor_identifier # 'DE98ZZZ09999999999'
    )

    for room in rooms
      if room.occupant.try(:bank_account).try(:iban).present?
        complete_subject = "#{subject} #{room.name}"

        sdd.add_transaction(
          # Name of the debtor, in German: "Zahlungspflichtiger"
          # String, max. 70 char
          name: room.occupant.bank_account.account_holder,

          # OPTIONAL: Business Identifier Code (SWIFT-Code) of the debtor's account
          # String, 8 or 11 char
          bic: room.occupant.bank_account.bic,

          # International Bank Account Number of the debtor's account
          # String, max. 34 chars
          iban: room.occupant.bank_account.iban.gsub(" ", ""),

          # Amount
          # Number with two decimal digit
          amount: room.rent.gsub(",", "."),

          # OPTIONAL: Currency, EUR by default (ISO 4217 standard)
          # String, 3 char
          currency: 'EUR',

          # OPTIONAL: Instruction Identification, will not be submitted to the debtor
          # String, max. 35 char
          instruction: room.name
            .parameterize(preserve_case: true, separator: ' '),

          # # OPTIONAL: End-To-End-Identification, will be submitted to the debtor
          # # String, max. 35 char
          # reference:                 'XYZ/2013-08-ABO/6789',

          # OPTIONAL: Unstructured remittance information, in German "Verwendungszweck"
          # String, max. 140 char
          remittance_information: complete_subject
            .parameterize(preserve_case: true, separator: ' '),

          # Mandate identifikation, in German "Mandatsreferenz"
          # String, max. 35 char
          mandate_id: mandate_id_for_user(room.occupant),               #'K-02-2011-12345',

          # Mandate Date of signature, in German "Datum, zu dem das Mandat unterschrieben wurde"
          # Date
          mandate_date_of_signature: mandate_date_of_signature_for_user(room.occupant),

          # Local instrument, in German "Lastschriftart"
          # One of these strings:
          #   'CORE' ("Basis-Lastschrift")
          #   'COR1' ("Basis-Lastschrift mit verkürzter Vorlagefrist")
          #   'B2B' ("Firmen-Lastschrift")
          local_instrument: 'CORE',

          # Sequence type
          # One of these strings:
          #   'FRST' ("Erst-Lastschrift")
          #   'RCUR' ("Folge-Lastschrift")
          #   'OOFF' ("Einmalige Lastschrift")
          #   'FNAL' ("Letztmalige Lastschrift")
          sequence_type: 'RCUR',

          # # OPTIONAL: Requested collection date, in German "Fälligkeitsdatum der Lastschrift"
          # # Date
          # requested_date: Date.new(2013,9,5),

          # OPTIONAL: Enables or disables batch booking, in German "Sammelbuchung / Einzelbuchung"
          # True or False
          batch_booking: true

          # # OPTIONAL: Use a different creditor account
          # # CreditorAccount
          # creditor_account: SEPA::CreditorAccount.new(
          #   name:                'Creditor Inc.',
          #   bic:                 'RABONL2U',
          #   iban:                'NL08RABO0135742099',
          #   creditor_identifier: 'NL53ZZZ091734220000'
          # )

          # # OPTIONAL: Specify the country & address of the debtor (REQUIRED for SEPA debits outside of EU. The individually required fields depend on the target country)
          # debtor_address: SEPA::DebtorAddress.new(
          #   country_code:        'CH',
          #   # Not required if individual fields are used
          #   address_line1:       'Mustergasse 123a',
          #   address_line2:       '1234 Musterstadt'
          #   # Not required if address_line1 and address_line2 are used
          #   street_name:         'Mustergasse',
          #   building_number:     '123a',
          #   post_code:           '1234',
          #   town_name:           'Musterstadt'
          # )
        )
      end
    end

    if sdd.valid?
      send_data sdd.to_xml,
        filename: "#{Time.zone.now} #{subject}".parameterize + '.xml',
        type: 'application/xml',
        disposition: 'attachment'
    else
      redirect_to :back, flash: {error: "Es gibt noch Probleme bei der Erstellung der XML-Datei: #{sdd.errors.full_messages.join("\n")}"}
    end
  end

  private

  def mandate_id_setting(user)
    institution.settings.where(var: "mandate_id_for_user_#{user.id}").first_or_create
  end

  def mandate_id_for_user(user)
    mandate_id_setting(user).value
  end

  def mandate_date_setting(user)
    institution.settings.where(var: "mandate_date_of_signature_for_user_#{user.id}").first_or_create
  end

  def mandate_date_of_signature_for_user(user)
    mandate_date_setting(user).value.try(:to_date)
  end


end