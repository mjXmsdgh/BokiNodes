extends PanelContainer

# --- UIノードへの参照 ---
# HBoxContainerを追加した場合のパスの例
@onready var bs_pl_container: HBoxContainer = $HBoxContainer
@onready var asset_total_label: Label = $HBoxContainer.get_node("貸借対照表(BS)/資産合計")
@onready var liability_total_label: Label = $HBoxContainer.get_node("貸借対照表(BS)/負債合計")
@onready var equity_total_label: Label = $HBoxContainer.get_node("貸借対照表(BS)/純資産合計")

# 損益計算書 (P/L)
@onready var revenue_total_label: Label = $HBoxContainer.get_node("損益計算書(PL)/収益合計")
@onready var expense_total_label: Label = $HBoxContainer.get_node("損益計算書(PL)/費用合計")
@onready var net_income_label: Label = $HBoxContainer.get_node("損益計算書(PL)/当期純利益")

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
	var asset_total = data.get("asset_total", 0)
	var liability_total = data.get("liability_total", 0)
	# B/Sの純資産は、当期純利益を含んだ最終的な値を表示します。
	var final_equity_total = data.get("final_equity_total", 0)
	var revenue_total = data.get("revenue_total", 0)
	var expense_total = data.get("expense_total", 0)
	var net_income = data.get("net_income", 0)

	# str()で一度文字列に変換し、%のフォーマット機能で桁区切りを実現します。
	# 整数部が0の場合でも "0" と表示されるようにしています。
	asset_total_label.text = "¥%s" % str(asset_total).format({"value": asset_total}, ",")
	liability_total_label.text = "¥%s" % str(liability_total).format({"value": liability_total}, ",")
	equity_total_label.text = "¥%s" % str(final_equity_total).format({"value": final_equity_total}, ",")

	revenue_total_label.text = "¥%s" % str(revenue_total).format({"value": revenue_total}, ",")
	expense_total_label.text = "¥%s" % str(expense_total).format({"value": expense_total}, ",")
	net_income_label.text = "¥%s" % str(net_income).format({"value": net_income}, ",")
