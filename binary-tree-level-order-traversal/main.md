## Step1
- treeの各深さのノードを左から右の順にまとめて配列にして返す
制約
- nodeの数 => 0 ~ 2000
- node.val => 負もある

normal
Input: root = [3,9,20,null,null,15,7]
Output: [[3],[9,20],[15,7]]

border
1. 
in: []
out: []
2.
in: node数が2000, 左右片方に集中
out: [[1], [2], ...]

edge
N/A

Approach
- BFS
    - time complexity: O(N)
    - space: O(W) W: 最大N/2

BFSで実装する
```py
class Solution:
    def levelOrder(self, root: Optional[TreeNode]) -> List[List[int]]:
        if not root:
            return []

        frontiers = deque()
        frontiers.append((root, 0))
        level_order_list = [[]]
        while frontiers:
            node, level = frontiers.popleft()
            if len(level_order_list) <= level:
                level_order_list.append([])
            level_order_list[level].append(node.val)
            if node.left is not None:
                frontiers.append((node.left, level + 1))
            if node.right is not None:
                frontiers.append((node.right, level + 1))
        
        return level_order_list
```

### 変数の命名
- level_order_list以外にlevel_ordered_values, each_level_node_values

## Step2　コメントや他の人のPRを見る

- if vs while
https://discord.com/channels/1084280443945353267/1200089668901937312/1211248049884499988
>私は、while だと思っていて、上から読んでいくと、「level が大きくて nodes_ordered_by_level が足りない場合、足りるように拡張します。そして、拡張した場所に書き込みます。」(読んでいくと、あとから、足りないことがあったとしても1段であることが他のところから分かる。)
> 「level が大きくて nodes_ordered_by_level が足りない場合、1段だけ拡張します。そして、level 番目に書き込みます。(書き込めなかったら IndexError が投げられます。)」(読んでいくと、1段だけしか拡張しなくても、level 番目が準備されているので例外はないことが分かる。)

>というふうに読めます。どっちが読み手にとっていいですか。
1段だけしか拡張しなくても例外が投げられることがないことに気がつくパズルを解かせる必要ないですよね。そうすると、下にするならば、コメント1行付けておいて、くらいの感覚です。

ifだと読み手に問題がないことを検証させる手間が発生する
```diff
--- if len(level_order_list) <= level:
---     level_order_list.append([])
+++ while len(level_order_list) <= level:
+++     level_order_list.append([])
```

- https://github.com/tom4649/Coding/pull/25#discussion_r2973146836
> キューにはなるべく処理に必要な情報がセットで入っていてほしいと思います（あくまで私の場合）。したがって、キュー外での管理になっている level_size はタプルにしてキューに詰めるか、next_level_nodes: list[TreeNode] に次の階層のnodeをappendしてqueueに差し替える、という実装の方が好みです。

上記の２つめの方法を実装する
```py
class Solution:
    def levelOrder(self, root: Optional[TreeNode]) -> List[List[int]]:
        if not root:
            return []

        current_level_nodes = [root]
        level_ordered_list = []
        while current_level_nodes:
            next_level_nodes = []
            values = []
            for node in current_level_nodes:
                values.append(node.val)
                if node.left is not None:
                    next_level_nodes.append(node.left)
                if node.right is not None:
                    next_level_nodes.append(node.right)
            current_level_nodes = next_level_nodes
            level_ordered_list.append(values)
        return level_ordered_list
```

## Step3
dequeを使わない実装. 同じ階層のノードを処理し、次の階層のノードのリストを差し替える
```py
class Solution:
    def levelOrder(self, root: Optional[TreeNode]) -> List[List[int]]:
        if not root:
            return []

        current_level_nodes = [root]
        level_ordered_list = []
        while current_level_nodes:
            next_level_nodes = []
            values = []
            for node in current_level_nodes:
                values.append(node.val)
                if node.left is not None:
                    next_level_nodes.append(node.left)
                if node.right is not None:
                    next_level_nodes.append(node.right)
            current_level_nodes = next_level_nodes
            level_ordered_list.append(values)
        return level_ordered_list
```