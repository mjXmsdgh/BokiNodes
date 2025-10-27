class_name FinancialStatementPanel
extends PanelContainer

@onready var asset_total_label: Label = %AssetTotalLabel
@onready var liability_total_label: Label = %LiabilityTotalLabel
@onready var equity_total_label: Label = %EquityTotalLabel
@onready var revenue_total_label: Label = %RevenueTotalLabel
@onready var expense_total_label: Label = %ExpenseTotalLabel
@onready var net_profit_label: Label = %NetProfitLabel


func _ready() -> void:
	# FinancialStatementManagerシングルトンのシグナルに接続する
	FinancialStatementManager.statements_updated.connect(_on_statements_updated)
	
	# 初期表示のために、一度手動で計算を要求する
	FinancialStatementManager.calculate_statements()


# FinancialStatementManagerからデータが更新されたときに呼び出される関数
func _on_statements_updated(data: FinancialStatementData) -> void:
	# 受け取ったデータで各Labelのテキストを更新する
	# format_currency関数で数値を読みやすい通貨形式に変換する
	asset_total_label.text = format_currency(data.asset_total)
	liability_total_label.text = format_currency(data.liability_total)
	equity_total_label.text = format_currency(data.equity_total)
	revenue_total_label.text = format_currency(data.revenue_total)
	expense_total_label.text = format_currency(data.expense_total)
	net_profit_label.text = format_currency(data.net_profit)

# 数値を "¥ 1,000" のような形式の文字列に変換するヘルパー関数
func format_currency(value: int) -> String:
	return "¥ {:,}".format({"value": value}).replace(",", ",")