extends PanelContainer

# --- UIノードへの参照 ---
# 貸借対照表 (B/S)
@onready var asset_total_label: Label = $"貸借対照表(BS)/資産合計"
@onready var liability_total_label: Label = $"貸借対照表(BS)/負債合計"
@onready var equity_total_label: Label = $"貸借対照表(BS)/純資産合計"

# 損益計算書 (P/L)
@onready var revenue_total_label: Label = $"損益計算書(PL)/収益合計"
@onready var expense_total_label: Label = $"損益計算書(PL)/費用合計"
@onready var net_income_label: Label = $"損益計算書(PL)/当期純利益"

# --- シングルトンへの参照 ---
@onready var financial_statement_manager: Node = FinancialStatementManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# FinancialStatementManagerのstatements_updatedシグナルを、
	# このスクリプトの_on_statements_updated関数に接続します。
	# これにより、計算結果が更新されるたびにUIが自動で更新されるようになります。
	if financial_statement_manager:
		financial_statement_manager.statements_updated.connect(_on_statements_updated)
	else:
		printerr("FinancialStatementPanel: FinancialStatementManager singleton not found.")

	# UIが表示されたときに、現在の財務諸表データを取得して一度表示を更新します。
	update_display(financial_statement_manager.calculate_statements())


## FinancialStatementManagerから更新通知シグナルを受け取ったときに呼び出される関数
func _on_statements_updated(statements_data: Dictionary) -> void:
	update_display(statements_data)


## 受け取ったデータでLabelの表示を更新する関数
func update_display(data: Dictionary) -> void:
	if data.is_empty():
		return

	# 辞書のデータを各Labelのtextプロパティに設定します。
	# 数値を3桁区切りの文字列にフォーマットして表示します。
	asset_total_label.text = "¥{:,}".format({"value": data.get("asset_total", 0)})
	liability_total_label.text = "¥{:,}".format({"value": data.get("liability_total", 0)})
	# B/Sの純資産は、当期純利益を含んだ最終的な値を表示します。
	equity_total_label.text = "¥{:,}".format({"value": data.get("final_equity_total", 0)})

	revenue_total_label.text = "¥{:,}".format({"value": data.get("revenue_total", 0)})
	expense_total_label.text = "¥{:,}".format({"value": data.get("expense_total", 0)})
	net_income_label.text = "¥{:,}".format({"value": data.get("net_income", 0)})
