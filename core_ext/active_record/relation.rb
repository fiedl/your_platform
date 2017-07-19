module ActiveRecord
  class Relation
    module WhereClauseOverrides
      def predicates_except(columns)
        super.reject do |node|
          case node
          when Arel::Nodes::Grouping
            sql = node.to_sql
            columns.any? { |column| sql.include? "\`#{column}\`" }
          when String
            columns.any? { |column| node.include? "\`#{column}\`" }
          end
        end
      end
    end

    class WhereClause
      prepend WhereClauseOverrides
    end
  end
end
