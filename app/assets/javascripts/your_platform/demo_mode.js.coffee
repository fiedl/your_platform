$(document).ready ->
  if $('.user .box_title').text().includes("Mustermann")
    $('body').addClass('mustermann')

  $('a:contains("Mustermann")').addClass('mustermann')

  $('.term_report_members tr:contains("Mustermann")').each ->
    $(this).find('td').addClass('mustermann')
    $(this).next('tr.second_for_member').find('td').addClass('mustermann')