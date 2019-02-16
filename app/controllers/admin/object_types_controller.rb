# frozen_string_literal: true

module Admin
  class ObjectTypesController < BaseController
    before_action :set_object_type, only: %i[show update destroy]

    def index
      opts = frontend_list_opts

      if opts[:ids].present?
        @object_types = ObjectType.where(id: opts[:ids])
        render json: @object_types, root: :data

      else
        conditions = []

        conditions << '(LOWER(name) LIKE :search_string)' if opts[:search_string].present?

        sorting = %w[id name].include?(opts[:sort_field]) ? "ORDER BY #{opts[:sort_field]} #{opts[:sort_order]}" : ''
        paging = opts[:limit].present? ? 'LIMIT :limit OFFSET :offset' : ''

        query = "
            SELECT *, COUNT(*) OVER() AS total
            FROM #{ObjectType.table_name}
        #{conditions.present? ? "WHERE #{conditions.join(' AND ')}" : ''}
        #{sorting}
        #{paging}"

        sql = query.match?(/:\w+/) ? ObjectType.send(:sanitize_sql_array, [query, opts]) : query

        rows = ObjectType.connection.select_all(sql)

        object_type_ids = rows.map { |r| r['id'].to_i }
        total = rows.empty? ? 0 : rows[0]['total'].to_i

        object_type_map = ObjectType.where(id: object_type_ids).to_a.index_by(&:id)
        @object_types = object_type_ids.map { |id| object_type_map[id] }

        render json: @object_types, root: :data, meta: { total: total }
      end
    end

    def show
      render json: @object_type
    end

    def create
      @object_type = ObjectType.new(object_type_params)

      if @object_type.save
        render json: @object_type, status: :created
      else
        render json: { errors: @object_type.errors }, status: :unprocessable_entity
      end
    end

    def update
      if @object_type.update(object_type_params)
        render json: @object_type
      else
        render json: { errors: @object_type.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      if @object_type.destroy
        render json: @object_type
      else
        head :unprocessable_entity
      end
    end

    private

    def set_object_type
      @object_type = ObjectType.find(params[:id])
    end

    def object_type_params
      params.require(:object_type).permit(:name)
    end
  end
end
