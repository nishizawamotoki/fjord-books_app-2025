class CreateReportMentions < ActiveRecord::Migration[8.0]
  def change
    create_table :report_mentions do |t|
      t.references :mentioning_report, null: false, foreign_key: { to_table: :reports }
      t.references :mentioned_report, null: false, foreign_key: { to_table: :reports }

      t.timestamps
    end

    add_index :report_mentions, [:mentioning_report_id, :mentioned_report_id], unique: true
  end
end
