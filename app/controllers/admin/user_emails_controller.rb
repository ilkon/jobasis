# frozen_string_literal: true

module Admin
  class UserEmailsController < BaseController
    before_action :set_user_email, only: %i[show update destroy]

    def index
      opts = frontend_list_opts

      if opts[:ids].present?
        @user_emails = UserEmail.where(id: opts[:ids])
        render json: @user_emails, root: :data

      else
        conditions = []
        conditions << 'UE.user_id = :user_id' if opts[:user_id].present?
        conditions << '(LOWER(UE.email) LIKE :search_string)' if opts[:search_string].present?

        sorting = %w[id email confirmed_at user_id].include?(opts[:sort_field]) ? "ORDER BY #{opts[:sort_field]} #{opts[:sort_order]}" : ''
        paging = opts[:limit].present? ? 'LIMIT :limit OFFSET :offset' : ''

        query = "
            SELECT
                UE.id,
                COUNT(*) OVER() AS total
            FROM #{UserEmail.table_name} UE
            #{conditions.present? ? "WHERE #{conditions.join(' AND ')}" : ''}
            #{sorting}
            #{paging}"

        sql = query.match?(/:\w+/) ? UserEmail.send(:sanitize_sql_array, [query, opts]) : query

        rows = UserEmail.connection.select_all(sql)

        user_email_ids = rows.map { |r| r['id'].to_i }
        total = rows.empty? ? 0 : rows[0]['total'].to_i

        user_email_map = UserEmail.where(id: user_email_ids).to_a.index_by(&:id)
        @user_emails = user_email_ids.map { |id| user_email_map[id] }

        render json: @user_emails, root: :data, meta: { total: total }
      end
    end

    def show
      render json: @user_email
    end

    def create
      @user_email = UserEmail.new(user_email_params)

      if @user_email.save
        render json: @user_email, status: :created
      else
        render json: { errors: @user_email.errors }, status: :unprocessable_entity
      end
    end

    def update
      # Not a real update
      # Here we resend confirmation email only
      token = @user_email.set_confirm_token
      Auth::Mailer.confirm_email_instruction(@user_email.email, @user_email.user, token).deliver_later

      render json: @user_email
    end

    def destroy
      if @user_email.destroy
        render json: @user_email
      else
        head :unprocessable_entity
      end
    end

    private

    def set_user_email
      @user_email = UserEmail.find(params[:id])
    end

    def user_email_params
      params.require(:user_email).permit(:user_id, :email)
    end
  end
end
