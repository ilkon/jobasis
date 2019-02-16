# frozen_string_literal: true

module Admin
  class IntentionsController < BaseController
    before_action :set_intention, only: %i[show update destroy]

    def index
      opts = frontend_list_opts

      if opts[:ids].present?
        @intentions = Intention.where(id: opts[:ids])
        render json: @intentions, root: :data

      else
        conditions = []

        conditions << '(LOWER(name) LIKE :search_string)' if opts[:search_string].present?

        sorting = %w[id name].include?(opts[:sort_field]) ? "ORDER BY #{opts[:sort_field]} #{opts[:sort_order]}" : ''
        paging = opts[:limit].present? ? 'LIMIT :limit OFFSET :offset' : ''

        query = "
            SELECT *, COUNT(*) OVER() AS total
            FROM #{Intention.table_name}
            #{conditions.present? ? "WHERE #{conditions.join(' AND ')}" : ''}
            #{sorting}
        #{paging}"

        sql = query.match?(/:\w+/) ? Intention.send(:sanitize_sql_array, [query, opts]) : query

        rows = Intention.connection.select_all(sql)

        intention_ids = rows.map { |r| r['id'].to_i }
        total = rows.empty? ? 0 : rows[0]['total'].to_i

        intention_map = Intention.where(id: intention_ids).to_a.index_by(&:id)
        @intentions = intention_ids.map { |id| intention_map[id] }

        render json: @intentions, root: :data, meta: { total: total }
      end
    end

    def show
      render json: @intention
    end

    def create
      @intention = Intention.new(intention_params)

      if @intention.save
        render json: @intention, status: :created
      else
        render json: { errors: @intention.errors }, status: :unprocessable_entity
      end
    end

    def update
      if @intention.update(intention_params)
        render json: @intention
      else
        render json: { errors: @intention.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      if @intention.destroy
        render json: @intention
      else
        head :unprocessable_entity
      end
    end

    private

    def set_intention
      @intention = Intention.find(params[:id])
    end

    def intention_params
      params.require(:intention).permit(:name)
    end
  end
end
