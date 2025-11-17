class PlanoDePagamento < ApplicationRecord
  belongs_to :responsavel_financeiro
  belongs_to :centro_de_custo
  has_many :cobrancas, dependent: :destroy
  accepts_nested_attributes_for :cobrancas

  def calcular_total!
    if self.respond_to?(:total_cents)
      update!(total_cents: cobrancas.sum(:valor_cents))
    else
      update!(valor_total: (cobrancas.sum(:valor_cents).to_f / 100.0))
    end
  end

  def total_money
    cents = if self.respond_to?(:total_cents) && total_cents
      total_cents
    else
      cobrancas.sum(:valor_cents)
    end
    Money.new(cents.to_i, "BRL")
  end
end
