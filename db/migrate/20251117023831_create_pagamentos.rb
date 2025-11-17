class CreatePagamentos < ActiveRecord::Migration[8.1]
  def change
    create_table :pagamentos do |t|
      t.references :cobranca, null: false, foreign_key: true
      t.integer :valor_cents, null: false
      t.date :data_pagamento, null: false

      t.timestamps
    end
  end
end
