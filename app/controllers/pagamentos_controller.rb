class PagamentosController < ApplicationController
  before_action :set_cobranca, only: [ :create ]

  def create
    service = Pagamentos::RegistrarPagamento.new(cobranca: @cobranca, params: create_pagamento_params, request: request)
    pagamento = service.call
    if pagamento
      render json: pagamento, status: :created
    else
      render json: { errors: service.errors }, status: :unprocessable_content
    end
  end

  private

  def set_cobranca
    @cobranca = Cobranca.find(params[:cobranca_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Cobrança não encontrada" }, status: :not_found
  end

  def create_pagamento_params
    if params[:pagamento].present?
      params.require(:pagamento).permit(
        :valor,
        :valor_cents,
        :data_pagamento,
        :dataPagamento,
        :referencia
      )
    elsif params[:payload].present?
      params.require(:payload).permit(
        :valor,
        :valor_cents,
        :data_pagamento,
        :dataPagamento,
        :referencia
      )
    else
      ActionController::Parameters.new(
        valor: params[:valor],
        valor_cents: params[:valor_cents],
        data_pagamento: params[:data_pagamento] || params[:dataPagamento],
        referencia: params[:referencia]
      )
    end
  end
end
