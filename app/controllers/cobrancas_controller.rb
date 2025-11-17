# app/controllers/cobrancas_controller.rb

class CobrancasController < ApplicationController
  # GET /cobrancas/index_por_responsavel?responsavel_id=...&metodoPagamento=...
  def index_por_responsavel
    # Movemos a lógica de scope para o modelo
    @cobrancas = Cobranca.por_responsavel(params[:responsavel_id])

    # Aplicamos filtros do params, assumindo que scopes foram criados no modelo
    @cobrancas = @cobrancas.por_metodo_pagamento(params[:metodoPagamento]) if params[:metodoPagamento].present?
    @cobrancas = @cobrancas.por_status(params[:status]) if params[:status].present?

    # O filtro de 'vencida' é um scope booleano no banco de dados, não filtragem em memória
    if params[:vencida] == "true"
      @cobrancas = @cobrancas.vencidas
    end

    # Usando Active Model Serializers ou .as_json para renderização limpa
    render json: @cobrancas.as_json(methods: [ :vencida?, :plano_id ])
    # Se estiver usando AMS, pode ser render json: @cobrancas
  end

  # GET /cobrancas/quantidade_por_responsavel?responsavel_id=...
  def quantidade_por_responsavel
    # Reutilizamos o scope do modelo para manter consistência
    count = Cobranca.por_responsavel(params[:responsavel_id]).count
    render json: { quantidade: count }
  end
end
