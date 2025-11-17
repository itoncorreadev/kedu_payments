class PagamentosController < ApplicationController
  before_action :set_cobranca, only: [ :create ]

  # POST /cobrancas/:cobranca_id/pagamentos
  def create
    # 1. Usando strong parameters para segurança
    pagamento_params = create_pagamento_params

    # 2. A lógica de conversão foi movida para um método privado
    valor_cents = to_cents(pagamento_params[:valor] || pagamento_params[:valor_cents])

    @pagamento = @cobranca.pagamentos.build(
      valor_cents: valor_cents,
      data_pagamento: pagamento_params[:data_pagamento] || pagamento_params[:dataPagamento],
      referencia: pagamento_params[:referencia] # Adicionei referencia, caso ela seja usada no seu modelo
    )

    if @pagamento.save
      render json: @pagamento, status: :created
    else
      render json: { errors: @pagamento.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Encontra a cobrança e lida com o caso de não ser encontrada (RecordNotFound)
  def set_cobranca
    @cobranca = Cobranca.find(params[:cobranca_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Cobrança não encontrada" }, status: :not_found
  end

  # Define os strong parameters permitidos
  def create_pagamento_params
    params.require(:pagamento).permit(
      :valor,
      :valor_cents,
      :data_pagamento,
      :dataPagamento,
      :referencia # Adicione outros campos necessários aqui
    )
  end

  # Helper privado para conversão de valor monetário (melhor prática com BigDecimal)
  def to_cents(valor)
    return 0 if valor.blank?
    # Usa BigDecimal para evitar erros de ponto flutuante em cálculos financeiros
    (BigDecimal(valor.to_s) * 100).to_i
  end
end
