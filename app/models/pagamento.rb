class Pagamento < ApplicationRecord
  belongs_to :cobranca

  validates :valor_cents, numericality: { greater_than: 0 }
  validate :nao_permitido_em_cancelada

  after_create :marcar_cobranca_paga

  def valor_money
    return nil unless valor_cents
    Money.new(valor_cents, "BRL")
  end

  private

  def nao_permitido_em_cancelada
    errors.add(:cobranca, "cancelada não pode receber pagamento") if cobranca.status_cancelada?
  end

  def marcar_cobranca_paga
    cobranca.update!(status: :paga)
  end
end
