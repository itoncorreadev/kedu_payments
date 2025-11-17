class PagamentosController < ApplicationController
  before_action :set_cobranca, only: [ :create ]

  def create
    pagamento_params = create_pagamento_params
    pagamento_params = (
      pagamento_params.respond_to?(:to_unsafe_h) ? pagamento_params.to_unsafe_h : pagamento_params.to_h
    ).deep_symbolize_keys

    valor_param = pagamento_params[:valor] || pagamento_params["valor"]
    if valor_param.blank?
      body_params = request.request_parameters
      valor_param = body_params["valor"] || body_params.dig("pagamento", "valor") || body_params.dig("payload", "valor")
    end
    valor_cents_param = pagamento_params[:valor_cents] || pagamento_params["valor_cents"]
    valor_cents = valor_param.present? ? to_cents(valor_param) : valor_cents_param.to_i

    attrs = {
      valor_cents: valor_cents,
      data_pagamento: pagamento_params[:data_pagamento] || pagamento_params[:dataPagamento]
    }
    @pagamento = @cobranca.pagamentos.build(attrs)

    if @pagamento.save
      render json: @pagamento, status: :created
    else
      render json: { errors: @pagamento.errors.full_messages }, status: :unprocessable_content
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

  def to_cents(valor)
    return 0 if valor.blank?
    Money.from_amount(BigDecimal(valor.to_s), "BRL").cents
  end
end
