# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show update destroy]

    def index
      opts = frontend_list_opts

      if opts[:ids].present?
        @users = User.where(id: opts[:ids]).includes(:user_role, :user_emails)
        render json: @users, root: :data

      else
        conditions = []

        conditions << '(LOWER(U.name) LIKE :search_string OR LOWER(UE.email) LIKE :search_string)' if opts[:search_string].present?

        sorting = %w[id name email].include?(opts[:sort_field]) ? "ORDER BY #{opts[:sort_field]} #{opts[:sort_order]}" : ''
        paging = opts[:limit].present? ? 'LIMIT :limit OFFSET :offset' : ''

        query = "
            SELECT
                U.id,
                MAX(U.name) AS name,
                STRING_AGG(UE.email, ',' ORDER BY UE.email) AS email,
                COUNT(*) OVER() AS total
            FROM #{User.table_name} U
                LEFT JOIN #{UserEmail.table_name} UE ON UE.user_id = U.id
            #{conditions.present? ? "WHERE #{conditions.join(' AND ')}" : ''}
            GROUP BY U.id
            #{sorting}
            #{paging}"

        sql = query.match?(/:\w+/) ? User.send(:sanitize_sql_array, [query, opts]) : query

        rows = User.connection.select_all(sql)

        user_ids = rows.map { |r| r['id'].to_i }
        total = rows.empty? ? 0 : rows[0]['total'].to_i

        user_map = User.where(id: user_ids).includes(:user_role, :user_emails).to_a.index_by(&:id)
        @users = user_ids.map { |id| user_map[id] }

        render json: @users, root: :data, meta: { total: total }
      end
    end

    def show
      render json: @user
    end

    def create
      @user = User.new(user_params)

      if @user.save
        render json: @user, status: :created
      else
        render json: { errors: @user.errors }, status: :unprocessable_entity
      end
    end

    def update
      if @user.update(user_params)
        render json: @user
      else
        render json: { errors: @user.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      if @user.destroy
        render json: @user
      else
        head :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name)
    end
  end
end
