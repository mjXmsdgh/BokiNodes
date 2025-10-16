class_name TransactionIndicator
extends Node2D

@onready var amount_label: Label = $AmountLabel


func set_amount(amount: float):
	# 日本円形式の文字列にフォーマットして表示
	amount_label.text = "¥{:,}".format({"":"{0}".format([amount])})
