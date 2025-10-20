extends Node

const TransactionIndicatorScene = preload("res://scenes/TransactionIndicator.tscn")

# 取引を可視化し、生成したインジケーターのインスタンスを返す
func visualize_transaction(transaction: Transaction, boki_nodes: Dictionary, container: Node) -> Node2D:
	print("--- [Visualizer] visualize_transaction: 取引の可視化を開始 ---")
	var from_node = boki_nodes.get(transaction.from_account_id)
	var to_node = boki_nodes.get(transaction.to_account_id)
	
	if not (from_node and to_node):
		print("  - [エラー] 可視化のためのFrom/Toノードが見つかりません。")
		return null

	# 矢印の親(container)からの相対位置を使用する
	var from_pos = from_node.position
	var to_pos = to_node.position
	
	var indicator_instance = TransactionIndicatorScene.instantiate()
	container.add_child(indicator_instance)
	
	# 1. 位置: 2つのノードのちょうど真ん中に配置する
	indicator_instance.position = from_pos.lerp(to_pos, 0.5)
	# 2. 角度: FromノードからToノードの方向に向ける
	indicator_instance.rotation = from_pos.angle_to_point(to_pos)
	# 3. 長さ: 2点間の距離に合わせて矢印の長さを調整する
	var distance = from_pos.distance_to(to_pos)
	indicator_instance.scale.x = distance / 100.0 # Polygon2Dの基本の長さ(100px)で割る
	indicator_instance.set_amount(transaction.amount)
	
	print("--- [Visualizer] visualize_transaction: 可視化完了 ---")
	return indicator_instance