# app/models/cobranca.rb

class Cobranca < ApplicationRecord
  belongs_to :plano_de_pagamento

  enum :metodo_pagamento, { boleto: 0, pix: 1 }, prefix: true
  enum :status, { emitida: 0, paga: 1, cancelada: 2 }, prefix: true

  validates :valor_cents, numericality: { greater_than: 0 }
  validates :data_vencimento, presence: true
  validates :metodo_pagamento, presence: true

  before_create :gerar_codigo_pagamento
  after_commit -> { plano_de_pagamento.calcular_total! }, on: [ :create, :update, :destroy ]

  # --- SCOPES ADICIONADOS PARA O CONTROLADOR ---

  # Scope principal para filtrar por responsável financeiro
  scope :por_responsavel, ->(responsavel_id) do
    joins(:plano_de_pagamento)
      .where(plano_de_pagamentos: { responsavel_financeiro_id: responsavel_id })
  end

  # Scope para buscar cobranças vencidas diretamente no banco de dados
  scope :vencidas_sql, -> {
    where("data_vencimento < ?", Date.current)
      .where.not(status: statuses[:paga])
      .where.not(status: statuses[:cancelada])
  }

  # Os enums `metodo_pagamento_...` e `status_...` já funcionam como scopes automaticamente.
  # Por exemplo: `Cobranca.metodo_pagamento_boleto` ou `Cobranca.status_emitida`

  # --- MÉTODOS DE INSTÂNCIA ---

  def vencida?
    # Este método é usado em memória (para objetos individuais)
    Date.current > data_vencimento && !status_paga? && !status_cancelada?
  end

  # Métodos auxiliares para uso no `render json:` do controlador
  def plano_id
    plano_de_pagamento_id
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
