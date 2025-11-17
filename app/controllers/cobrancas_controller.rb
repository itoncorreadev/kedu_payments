# app/controllers/cobrancas_controller.rb

class CobrancasController < ApplicationController
  def index_por_responsavel
    service = Cobrancas::ConsultaPorResponsavel.new(params: params)
    cobrancas = service.listar
    render json: cobrancas, each_serializer: CobrancaSerializer
  end

  def quantidade_por_responsavel
    service = Cobrancas::ConsultaPorResponsavel.new(params: params)
    count = service.contar
    render json: { quantidade: count }
  end
end
