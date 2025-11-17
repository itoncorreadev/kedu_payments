class PagamentosController < ApplicationController
  before_action :set_cobranca, only: [ :create ]

  def create
    pagamento_params = create_pagamento_params

    valor_cents = to_cents(pagamento_params[:valor] || pagamento_params[:valor_cents])

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
