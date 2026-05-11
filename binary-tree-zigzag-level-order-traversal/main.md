## Step1
Binary Tree Level Order Traversalの応用バージョン. 奇数レベルは右から左の順になるように配列に格納する
- 制約
The number of nodes in the tree is in the range [0, 2000].
-100 <= Node.val <= 100

- normal case
    - Input: root = [3,9,20,null,null,15,7], Output: [[3],[20,9],[15,7]]
- border
    - In: [], Out: []

BFSで解く. 前問とは異なり, 奇数レベルのときは逆順に格納するようにする
以下はレベルごとに一括で処理をし, queueを差し替える方法
- 時間計算量:O(N)
- 空間計算量: O(W)最大N/2
```py
class Solution:
    def zigzagLevelOrder(self, root: Optional[TreeNode]) -> List[List[int]]:
        if not root:
            return []
        
        level = 0
        current_level = [root]
        level_ordered = []
        while current_level:
            values = []
            next_level = []
            for node in current_level:
                values.append(node.val)
                if node.left is not None:
                    next_level.append(node.left)
                if node.right is not None:
                    next_level.append(node.right)
            current_level = next_level
            if level % 2 == 1:
                level_ordered.append(values[::-1])
            else:
                level_ordered.append(values)
            level += 1
            
        return level_ordered 
```
AIレビュー
- level変数 — インデックスとして使っているが、level % 2 == 1の判定をboolフラグ（left_to_right = not left_to_right）にすると、zigzagの意図がより直接的に表現できます

```py
left_to_right = True
while current_level:
    ...
    if left_to_right:
        level_ordered.append(values)
    else:
        level_ordered.append(values[::-1])
    left_to_right = not left_to_right
```

- 反転ロジックがif/elseでappendを2回書いている。こう書くと1行にできます：
`level_ordered.append(values[::-1] if level % 2 else values)`
ただし好みの範囲です

- `reversed`と`list[::-1]`の違い
reversedはiteratorを返す

- queueを差し替えず, 逐次的に処理をする方法
    - 時間計算量:O(N)
    - 空間計算量: O(W)最大N/2
```py
class Solution:
    def zigzagLevelOrder(self, root: Optional[TreeNode]) -> List[List[int]]:
        if not root:
            return []
        
        level = 0
        frontiers = deque([(root, level)])
        level_ordered = []
        while frontiers:
            node, level = frontiers.popleft()
            while level >= len(level_ordered):
                level_ordered.append([])
            if level % 2 == 1:
                # 以下の処理を全ループで合計するとO(N)になる
                level_ordered[level].insert(0, node.val)
            else:
                level_ordered[level].append(node.val)
            if node.left is not None:
                frontiers.append((node.left, level + 1))
            if node.right is not None:
                frontiers.append((node.right, level + 1))

        return level_ordered
```
- `level_ordered[level].insert(0, node.val)`の部分はlevel_orderedの各子要素を`deque`にすると先頭への追加もO(1)になるので効率的（`deque`は双方向リストであるため）
- ただし, 最後にdequeからlistに変換する必要があるので全体の計算量オーダーは変わらないが, 毎回メモリシフトが発生するlist方式に比べて定数倍はやい
```py
class Solution:
    def zigzagLevelOrder(self, root: Optional[TreeNode]) -> List[List[int]]:
        if not root:
            return []
        
        level = 0
        frontiers = deque([(root, level)])
        level_ordered = []
        while frontiers:
            node, level = frontiers.popleft()
            while level >= len(level_ordered):
                level_ordered.append(deque())
            if level % 2 == 1:
                level_ordered[level].appendleft(node.val)
            else:
                level_ordered[level].append(node.val)
            if node.left is not None:
                frontiers.append((node.left, level + 1))
            if node.right is not None:
                frontiers.append((node.right, level + 1))

        # O(N)だけど軽い(memcpy?)
        return [list(d) for d in level_ordered]
```