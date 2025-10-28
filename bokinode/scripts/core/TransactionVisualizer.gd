# TransactionVisualizer.gd
# BokiNode間の取引をLine2Dを使って視覚的に表現する。

extends Node

# ステップ1で作成したTransactionIndicator.tscnをインスペクターから設定できるようにする
@export var transaction_indicator_scene: PackedScene

# 取引を可視化し、生成したインジケーターのインスタンスを返す
func visualize_transaction(transaction: Transaction, boki_nodes: Dictionary, container: Node) -> Node2D:
	print("--- [Visualizer] visualize_transaction: 取引の可視化を開始 ---")

	if not transaction_indicator_scene:
		push_error("TransactionIndicator scene is not set in the inspector.")
		return null

	var from_node = boki_nodes.get(transaction.from_account_id)
	var to_node = boki_nodes.get(transaction.to_account_id)

	if not (from_node and to_node):
		print("  - [エラー] 可視化のためのFrom/Toノードが見つかりません。")
		return null

	# 【インスタンス生成】TransactionIndicatorシーンの実体を作る
	var indicator_instance: Node2D = transaction_indicator_scene.instantiate()
	container.add_child(indicator_instance)

	# --- ここからが新しい可視化の処理 ---

	# From/Toノードのグローバル座標を取得
	var from_pos: Vector2 = from_node.global_position
	var to_pos: Vector2 = to_node.global_position

	# 1. ArrowLine (Line2D) の設定
	var arrow_line: Line2D = indicator_instance.get_node("ArrowLine")
	arrow_line.points = PackedVector2Array([from_pos, to_pos])

	# 2. ArrowHead (Polygon2D) の設定
	var arrow_head: Polygon2D = indicator_instance.get_node("ArrowLine/ArrowHead")
	arrow_head.position = to_pos
	arrow_head.rotation = from_pos.angle_to_point(to_pos)

	# 3. AmountLabel (Label) の設定
	var amount_label: Label = indicator_instance.get_node("AmountLabel")
	amount_label.text = "¥{num}".format({"num": str(transaction.amount).insert(str(transaction.amount).length() - 3, ",") if str(transaction.amount).length() > 3 else str(transaction.amount)})
	amount_label.global_position = from_pos.lerp(to_pos, 0.5)

	print("--- [Visualizer] visualize_transaction: 可視化完了 ---")
	return indicator_instance
