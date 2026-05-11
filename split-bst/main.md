Description
Given a binary search tree (BST) with a root node root and a target value v, the tree is partitioned into two subtrees, one of which has nodes that are both less than or equal to the target value and the other has nodes that are both greater than the target value, where the nodes of the given binary search tree root do not necessarily have nodes with values equal to v.

In addition, most of the structure of the original tree root should be preserved. Simply put, for any child node C that has a parent node P in the original tree, if they are both in the same subtree after the split, then the node C should still be a child node of P.

For the two split subtrees, the one with the highest number of nodes is returned, or if the two subtrees have the same number of nodes, the one with the largest root node value is returned.

The size of the BST will not exceed 50
The BST is always valid and each node's value is different

Input:
root = {4,2,6,1,3,5,7}
v = 2
Output:
{4,3,6,#,#,5,7}
Explanation:
The given tree {4,2,6,1,3,5,7} is represented as the following:

          4
        /   \
       2     6
      / \   / \
     1   3 5   7

The two subtrees after splitting are:

          4
        /   \
      3      6      and    2
            / \           /
           5   7         1

The subtree with 4 as the root node has more nodes, so it returns the left subtree.


以降、v以下のnodeを集めた部分木を左部分木、v以上を右部分木とする。

Approach
- nodeの値がv以下の時、node.leftは左部分木に入るので、nodeをルートとする部分木についてはnode.rightを探索すれば良い。ただnode.rightの中にv以下のnodeがあった場合に繋ぎかえるのがめんどくさそう。
- 初めはiterativeな解法で解こうとしたが、状態遷移が多くわからなかったのでヒントをもらったところ再帰で解くとのこと
（BST系は再帰がやりやすいかもしれない...）

💡 再帰関数を、nodeの左右の子を引数にとり、引数を根とする部分木を２つに分割してそれぞれの根を返す関数と設計する

時間計算量：O(N) 分割部分自体の時間計算量はO(H)になる。理由：各ノードで再帰するのは片側だけなので、各ノードにおいて、左右のどちらかに降りることをleaf nodeまで繰り返す。よって訪問するノード数は木の高さに等しい（💡木をどうやって辿るのかイメージする）
空間計算量：O(H)
```py
class Solution:
    """
    @param root: the given tree
    @param v: the target value
    @return: the root TreeNode after splitting
    """
    def split_b_s_t(self, root, v):
        def split_bst_helper(node):
            if node is None:
                return None, None

            if node.val <= v:
                left, right = split_bst_helper(node.right)
                # node.rightに、「node.rightを２つに分割したとき、v以下の集合」を割り当てる
                # rightの各ノードの値は、node.val < val <= vを満たす。
                node.right = left
                return node, right

            # 逆
            left, right = split_bst_helper(node.left)
            node.left = right
            return left, node

        # 数えるのは別で行う判断にした
        def count(node):
            if node is None:
                return 0
            return 1 + count(node.left) + count(node.right)

        left, right = split_bst_helper(root)

        if left is None:
            # edge
            return right
        if right is None:
            # edge
            return left

        count_left = count(left)
        count_right = count(right)

        if count_right > count_left:
            return right
        if count_left > count_right:
            return left
        return right if right.val >= left.val else left
```


iterativeの解法について
- 再帰関数には、現在のnodeを渡して、nodeを分割した左右の木を返してもらっている。
- 帰りがけに現在のnodeを編集(left or rightに部分木を割り当てる)しているので、iterativeにするにはstackを用いて、各ノードを逆順に走査できるようにし、ループ間で、左部分木・右部分木の根を引き回す

時間、空間計算量は同じ
```py
def split_b_s_t(self, root, v):
    stack = []
    node = root
    while node is not None:
        stack.append(node)
        if node.val <= v:
            node = node.right
        else:
            node = node.left
    
    left, right = None, None # 再帰の最後の戻り値 = iterativeでは出発点になる
    # iterativeでは、再帰関数の戻り値はループ間変数になる
    while stack:
        node = stack.pop()
        # 帰りがけの演算をする. 今のnodeに対して、left, rightに相当するものはループ間で引き回している -> 末尾再帰っぽい構造で使える
        if node.val <= v:
            node.right = left
            left = node # return node, rightに対応
        else:
            node.left = right
            right = node # return left, nodeに対応
    # (left, right)が分割結果になる

    """
    比較
    def split_bst_helper(node):
        if node is None:
            return None, None

        if node.val <= v:
            left, right = split_bst_helper(node.right)
            node.right = left
            return node, right

        left, right = split_bst_helper(node.left)
        node.left = right
        return left, node
    """
```

他のiterativeな方法
- 結構めんどくさそう
ここまでの解法は、再帰呼び出しを先にして子の結果をもらって自分の結果を作るbottom up再帰

topdownの再帰は綺麗に書けないらしいが、iterativeであれば空間計算量がO(1)で書ける。
最初にやろうとしていたのはこれっぽい
- cur.val <= vの時、左部分木がまだ一個もない時はcur自身が左部分木になり、cur.right
「進む方向のポインタは先に切ってから attach する」ことで、各ステップ終了時に中間状態が常に整合した形になる。最後の末端処理も不要。

必要な状態は以下
- 現在見ているノードを表す`cur`変数
- 左部分木の根
- 左部分木の最後に挿入したノード
- 右部分木の根
- 右部分木の最後に挿入したノード

```py
# 分割する部分は、時間計算量O(H) -> curが辿るのも片側だけなので
# 空間計算量はO(1)
def split(root, v):
    le_head = gt_head = None
    le_tail = gt_tail = None
    cur = root
    while cur:
        if cur.val <= v:
            # cur は ≤v 側。cur.right を辿って境界を探すので、先に cur.right を取り出して切る
            nxt = cur.right
            cur.right = None
            # cur を le 側の末尾に繋ぐ。cur.left は元の部分木のまま保持される
            if le_tail is None:
                le_head = cur
            else:
                le_tail.right = cur
            le_tail = cur
            cur = nxt
        else:
            # cur は >v 側。cur.left を辿るので、先に cur.left を取り出して切る
            nxt = cur.left
            cur.left = None
            if gt_tail is None:
                gt_head = cur
            else:
                gt_tail.left = cur
            gt_tail = cur
            cur = nxt
    return le_head, gt_head
```

各イテレーションでやっていること:
1. **進む方向のポインタを `nxt` に退避して、すぐ切る** (`cur.right = None` or `cur.left = None`)
2. cur を該当側の tail に attach
3. `cur = nxt` で次へ

「切ってから attach」の順なので、ループ後の末端処理が不要。

## Step2

### 具体例をたくさん挙げる発想法 ★最重要

[mamo3gr#58](https://github.com/mamo3gr/arai60/pull/58)
- 思考過程の参考
[goto-untrapped#54](https://github.com/goto-untrapped/Arai60/pull/54#discussion_r1780641914)
> 具体例のところが足りない気がしますね。もっと単純な例をたくさん考えています。
> 一番はじめは、target を 2.5 みたいな値だと思ってエッジケースに当たらないようにして考えます。
> そうすると、切らなくてはいけないエッジは、両側のノードの値が target をまたいでいるエッジですね。そして、その後、切ったところを繋がないといけませんね。繋ぎ方が問題になるのは切ったところが4つからですかね。
> ここまで考えてから、エッジケースをちょっと考えます。全体が target よりも大きかったり小さかったり。木のサイズが0,1などの場合です。
> それから他人にやってもらうにはどうやるかを説明できるようにして、それから機械にやり方を説明します。

ポイント:
1. **`target = 2.5` のような「絶対にツリー内の値と一致しない」値で考える** → 等号エッジケースを避けて、本質に集中できる
2. **「切らなければいけないエッジ = targetをまたぐエッジ」** という抽象化を先に得る
3. **繋ぎ方の難しさは切るエッジが4つから出る** → 単純例だけだと見えない構造が見える
4. エッジケース（全部targetより大/小、サイズ0,1）はその後
5. **「自分で手作業 → 人間に説明 → 機械に説明」の3段階**を意識

具体例は1つで済まさず**5個10個と挙げる**ことで、自分の理解の網目が見えてくる。

### 変数名: `left/right` より `smaller/larger`
[goto-untrapped#54](https://github.com/goto-untrapped/Arai60/pull/54)
> `left`, `right`より`smaller`, `larger`の分かりやすいかと思いました。

[naoto-iwase#48](https://github.com/naoto-iwase/leetcode/pull/48) 
> left, rightより、smaller, largerの方が情報が載ると思いました。
> left, rightはポインタのleft, rightとも混ざるのが良くない。

`node.left` / `node.right` という属性名と被るので、分割結果を `left, right` と命名すると混乱する。`smaller / larger`（あるいは `le / gt`）にすべき。

### 命名: 分割点 (split point)
[yumyum116#13](https://github.com/yumyum116/LeetCode_Arai60/pull/13)
> small_root・large_root のほうは split point (分割点) みたいな名前にしたほうが分かりやすいかもしれません。

iterative版の末端を指す変数を `xxx_root` と書くと「木の根」と混同される。`split_point`(分割点) や `tail` のような実態を表す名前に。

### if-else で左右の対称性を表現
[naoto-iwase#48](https://github.com/naoto-iwase/leetcode/pull/48)
> 左右の対称性をソースコードでも示すため、if else の形で書いたほうが良い

`if ... return` の早期returnスタイルだと対称性が見えにくい。**完全に対称な操作は `if/else` で並べる**ほうが構造が読みやすい。

### 必ず `large_root.val > small_root.val`
[naoto-iwase#48](https://github.com/naoto-iwase/leetcode/pull/48) 
> 必ず large_root.val のほうが大きくなると思います。

BST分割の性質上「同数のときは大きいルートを返す」というタイブレークは**実質ノード数だけで決まる**（large側が必ず勝つ）。`right.val >= left.val` の比較は常に真で本質的に冗長。

### Noneチェックを忘れがち
[naoto-iwase#48](https://github.com/naoto-iwase/leetcode/pull/48) 
> root がNoneのときや、部分木の根がNoneのとき、`if left_root.val > right_root.val` で AttributeError になるのが良くない。

ロジックが複雑になると Noneチェックを忘れる。**比較系の処理の前に必ず None ガード**を入れる

### ツーパスの方が読みやすい
[naoto-iwase#48](https://github.com/naoto-iwase/leetcode/pull/48)
> 一回ですることもできますが、おそらくこういう風にツーパスにしたほうが読みやすいでしょうね。
> また、ループに直すことも可能ですが、結構面倒です。

`split` と `count` を分離するツーパス版の方が、**関心の分離**ができていて読みやすい。1パス最適化は計算量が変わらないなら避けるべき。

### iterative版の番兵パターン
[mamo3gr#58](https://github.com/mamo3gr/arai60/pull/58)
> 番兵を使うとシンプルに書けそう。
> big は常に左の子ノードを待ち構えているように見える。

ダミーヘッド版では `small_dummy = TreeNode(val=-1)` のような番兵を置くと、「最初のノードかどうか」の if 分岐が消える。**すでにheadがあるものとして扱うことができる**

```python
small_dummy = TreeNode(val=-1)
small = small_dummy
# ...
small.right = node  # 最初も2回目以降も同じ書き方でOK
small = node
# ...
return small_dummy.right  # 番兵の次が本当の根
```
## 🤖類題

| 番号 | 問題名 | 関連 |
|---|---|---|
| **776** | Split BST | 本問（Premium） |
| **1110** | Delete Nodes And Return Forest | エッジを切ってフォレストを返す。一般 binary tree 版の発想に直結 |
| **669** | Trim a Binary Search Tree | 範囲外を削除。BSTで O(H) 再帰の構造が瓜二つ |


## Step3

```py
def split_bst(root, v):
    def split_bst_helper(node):
        # nodeを受け取って、nodeの部分木のうちv以下の部分木とvより大きい部分木を返す関数
        if node is None:
            return None, None

        if node.val <= v:
            le, gt = split_bst_helper(node.right)
            node.right = le
            return node, gt
        
        le, gt = split_bst_helper(node.left)
        node.left = gt
        return le, node
    
    le, gt = split_bst_helper(root)
    def count(node):
        if node is None:
            return 0
        
        return 1 + count(node.left) + count(node.right)

    if le is None:
        return gt
    
    if gt is None:
        return le
    
    le_count = count(le)
    gt_count = count(gt)
    if gt_count >= le_count:
        # 同数の時は、BSTの分割なので gt.val > le.valが常に成立する。
        return gt
    
    return le
```