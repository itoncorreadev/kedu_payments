class ResponsaveisController < ApplicationController
  def index
    @responsavel_financeiro = ResponsavelFinanceiro.all

    render json: @responsavel_financeiro
  end

  def show
    @responsavel_financeiro = ResponsavelFinanceiro.find(params[:id])

    render json: @responsavel_financeiro
  end

  def create
    @responsavel_financeiro = ResponsavelFinanceiro.new(responsavel_financeiro_params)
    if @responsavel_financeiro.save
      render json: @responsavel_financeiro, status: :created
    else
      render json: { errors: @responsavel_financeiro.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def responsavel_financeiro_params
    params.require(:responsavel_financeiro).permit(:nome)
  end
end
