class CreateCobrancas < ActiveRecord::Migration[8.1]
  def change
    create_table :cobrancas do |t|
      t.references :plano_de_pagamento, null: false, foreign_key: true
      t.integer :valor_cents, null: false
      t.date :data_vencimento, null: false
      t.integer :metodo_pagamento, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.string :codigo_pagamento

      t.timestamps
    end
    add_index :cobrancas, :codigo_pagamento
  end
end
