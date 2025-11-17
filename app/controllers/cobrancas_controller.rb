class CobrancasController < ApplicationController
  def index_por_responsavel
    @cobrancas = Cobranca.por_responsavel(params[:responsavel_id])

    @cobrancas = @cobrancas.por_metodo_pagamento(params[:metodoPagamento]) if params[:metodoPagamento].present?
    @cobrancas = @cobrancas.por_status(params[:status]) if params[:status].present?

    if params[:vencida] == "true"
      @cobrancas = @cobrancas.vencidas
    end

    render json: @cobrancas.as_json(methods: [ :vencida?, :plano_id ])
  end

  def quantidade_por_responsavel
    count = Cobranca.por_responsavel(params[:responsavel_id]).count
    render json: { quantidade: count }
  end
end
