class Cobranca < ApplicationRecord
  belongs_to :plano_de_pagamento
  has_many :pagamentos, dependent: :destroy

  enum :metodo_pagamento, { boleto: 0, pix: 1 }, prefix: true
  enum :status, { emitida: 0, paga: 1, cancelada: 2 }, prefix: true

  validates :valor_cents, numericality: { greater_than: 0 }
  validates :data_vencimento, presence: true
  validates :metodo_pagamento, presence: true

  before_create :gerar_codigo_pagamento
  after_commit -> { plano_de_pagamento.calcular_total! }, on: [ :create, :update, :destroy ]

  scope :por_responsavel, ->(responsavel_id) {
    where(plano_de_pagamento_id: PlanoDePagamento.where(responsavel_financeiro_id: responsavel_id.to_i).select(:id))
  }

  scope :por_metodo_pagamento, ->(nome) {
    valor = Cobranca.metodo_pagamentos[nome.to_s.downcase]
    where(metodo_pagamento: valor)
  }

  scope :por_status, ->(nome) {
    valor = Cobranca.statuses[nome.to_s.downcase]
    where(status: valor)
  }

  scope :vencidas, -> {
    where("data_vencimento < ? AND status NOT IN (?)", Date.current, [ Cobranca.statuses["paga"], Cobranca.statuses["cancelada"] ])
  }

  def vencida?
    Date.current > data_vencimento && !status_paga? && !status_cancelada?
  end

  def valor_money
    return nil unless valor_cents
    Money.new(valor_cents, "BRL")
  end

  private

  def gerar_codigo_pagamento
    self.codigo_pagamento =
      if metodo_pagamento_boleto?
        "BOLETO-#{SecureRandom.random_number(10**47).to_s.rjust(47, '0')}"
      else
        "PIX-#{SecureRandom.hex(16)}"
      end
  end
end
