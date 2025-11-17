class CentrosDeCustoController < ApplicationController
  def index
    render json: CentroDeCusto.all
  end

  def create
    centro_de_custo = CentroDeCusto.new(centro_de_custo_params)
    if centro_de_custo.save
      render json: centro_de_custo, status: :created
    else
      render json: { errors: c.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def centro_de_custo_params
    params.require(:centro_de_custo).permit(:nome)
  end
end
