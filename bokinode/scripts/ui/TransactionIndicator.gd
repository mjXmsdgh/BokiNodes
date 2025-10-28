class_name TransactionIndicator
extends Node2D

@onready var amount_label: Label = $AmountLabel


func set_amount(amount: float):
	#amount_label.text = "%s" % amount
	# 3桁ごとにカンマを入れる簡易的なロジック
	var amount_str = str(int(amount))
	amount_label.text = "¥{num}".format({"num": amount_str.insert(amount_str.length() - 3, ",") if amount_str.length() > 3 else amount_str})
