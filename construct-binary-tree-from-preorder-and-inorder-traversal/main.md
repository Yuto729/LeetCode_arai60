## Step1
Given two integer arrays preorder and inorder where preorder is the preorder traversal of a binary tree and inorder is the inorder traversal of the same tree, construct and return the binary tree.

Examples
1. normal
Input: preorder = [3,9,20,15,7], inorder = [9,3,15,20,7]
Output: [3,9,20,null,null,15,7]

2. border
Input: preorder = [-1], inorder = [-1]
Output: [-1]

3. normal
Input: preorder = [1,2,3,4,7], inorder = [2,1,3,4,7]

Output: [1,2,3,null,null,null,4,null,7]

Constraints:

- 1 <= preorder.length <= 3000
- inorder.length == preorder.length
- -3000 <= preorder[i], inorder[i] <= 3000
- preorder and inorder consist of unique values. => 木の中に同じ値のノードが存在しない
- Each value of inorder also appears in preorder.
- preorder is guaranteed to be the preorder traversal of the tree.
- inorder is guaranteed to be the inorder traversal of the tree

Approach
AIにヒントをもらう
- preorderの先頭要素は常にその部分木のroot
- 再帰を用いる
例1で考えてみる
1. 3がルートになる。inorderで3を検索。
2. 左側の[9]は左部分木, 右側の右側の[15,20,7]が右部分木になる
3. 9はrootの左部分木で確定. inorder: [15,20,7], preorder: [20,15,7]として同じことをする
preorderから[20,15,7]を切り出す方法 => 左部分木のノード数がinorderからわかるので, ノード数 = preorderにおける左右の分岐点になる

- 時間計算量: O(N**2) 
- 空間計算量: O(N) => preorder, inorder

かなり時間かかって解けた
実行時間は遅めの山のほう
```py
class Solution:
    def buildTree(self, preorder: List[int], inorder: List[int]) -> Optional[TreeNode]:
        assert len(preorder) == len(inorder)
        if not preorder:
            return None

        if len(preorder) == 1:
            return TreeNode(preorder[0])

        root_val = preorder[0]
        root = TreeNode(root_val)

        left_size = inorder.index(root_val)
        right_preorder = preorder[left_size+1: ]
        right_inorder = inorder[left_size+1: ]

        left_preorder = preorder[1: left_size+1]
        left_inorder = inorder[:left_size]

        root.right = self.buildTree(right_preorder, right_inorder)
        root.left = self.buildTree(left_preorder, left_inorder)
        return root
```

`inorder.index(root_val)`が毎回O(N)かかっているのが遅い原因っぽいのでhashmapをどうにかつかって解決できないか
- inorderの値とindexを結びつけるハッシュマップ
- サブツリーの作成をpreorder, inorderを切り取って渡すのではなくインデックスを渡すようにする(元の配列は変更しない)
上記によりスライスの作成コストが減少＆可読性もよくなる
実行時間が改善した
```py
class Solution:
    def buildTree(self, preorder: List[int], inorder: List[int]) -> Optional[TreeNode]:
        inorder_to_idx = {val: i for i, val in enumerate(inorder)}

        def build(pre_start, pre_end, in_start, in_end):
            if pre_start > pre_end:
                return None

            root_val = preorder[pre_start]
            root = TreeNode(root_val)

            idx = inorder_to_idx[root_val]
            left_size = idx - in_start

            root.left = build(pre_start + 1, pre_start + left_size, in_start, idx - 1)
            root.right = build(pre_start + left_size + 1, pre_end, idx + 1, in_end)
            return root

        return build(0, len(preorder) - 1, 0, len(inorder) - 1)
```

上記のスタックバージョン実装
```py
class Solution:
    def buildTree(self, preorder: List[int], inorder: List[int]) -> Optional[TreeNode]:
        inorder_to_idx = {val: i for i, val in enumerate(inorder)}

        root = TreeNode(preorder[0])
        # (node, pre_start, pre_end, in_start, in_end)
        stack = [(root, 0, len(preorder) - 1, 0, len(inorder) - 1)]

        while stack:
            node, pre_start, pre_end, in_start, in_end = stack.pop()

            idx = inorder_to_idx[node.val]
            left_size = idx - in_start

            r_pre_start = pre_start + left_size + 1
            if r_pre_start <= pre_end:
                node.right = TreeNode(preorder[r_pre_start])
                stack.append((node.right, r_pre_start, pre_end, idx + 1, in_end))

            l_pre_start = pre_start + 1
            l_pre_end = pre_start + left_size
            if l_pre_start <= l_pre_end:
                node.left = TreeNode(preorder[l_pre_start])
                stack.append((node.left, l_pre_start, l_pre_end, in_start, idx - 1))

        return root
```


## Step2
- https://github.com/goto-untrapped/Arai60/pull/53#discussion_r1780608187
> 「え、そもそも、Preorder と Inorder で再現できるだけの情報あるのかよ。異なる2つの木で Preorder と Inorder が同じになっちゃうような場合って本当にないの。」みたいな疑問をもって、それを解消に行く気がします。この疑問を解消しておくと、どういう作業をしたら元の木が決められるかが分かると思います。
「自分で手作業でできる」ようにして「人に手作業でできるように説明をする」というプロセスを踏むと、明らかに無駄なところは気がつくように思うんですよね。しかし、それはともかくそうだとしても、遅くてもいいから動くものを作ってしまうのは一つです。そちらのほうが簡単そうならば。

自分の一個目の解法はナイーブだけど手作業をそのままコードにしたもの

## preorderをイテレータで消費しつつ、inorderの範囲だけで再帰する方法
- https://github.com/fuga-98/arai60/pull/29/changes
上記の`nonlocal`で`pre_index`を進める解法と同じ。

なぜこれで動くか：preorderは「根→左→右」の順なので、左を先に再帰すれば、next()で取り出す順番がちょうどpreorderの順と一致する。だからpreorderのインデックス管理が不要で、inorderの範囲だけ渡せばいい。

- pros: preorderのインデックス管理が不要
- cons: next(pre_iter)は副作用なので引数で範囲を渡す方が好ましいという話もある
```py
def buildTree(self, preorder, inorder):
    inorder_idx = {val: i for i, val in enumerate(inorder)}
    pre_iter = iter(preorder)

    def build(in_start, in_end):
        if in_start > in_end:
            return None

        root_val = next(pre_iter)
        root = TreeNode(root_val)
        idx = inorder_idx[root_val]
        root.left = build(in_start, idx - 1)   # 左を先に呼ぶ
        root.right = build(idx + 1, in_end)
        return root

    return build(0, len(inorder) - 1)
```

### スライスのコピーコストをなくす

Pythonのリストスライスは毎回コピーが発生する。対策：
- **インデックス範囲方式** => 一番良い
- **Rustのslice**はゼロコピー（`&[i32]`）
- **`array.array` + `memoryview`** でもview的な操作が可能
    - https://github.com/Yoshiki-Iwasa/Arai60/pull/33#discussion_r1688357607
    array.arrayはint等の固定型でしか使えない

```python
from array import array
preorder_array = array('l', preorder)
mv = memoryview(preorder_array)  # スライスしてもコピーされない
```

### inorder順に構築するスタックベース解法

再帰を使わず、inorder順にノードを生成し、stackで`.right`が未確定のノードを管理する方法。`gather_descendants`関数でpreorderの位置関係を使い、stackからノードを回収して`.right`で数珠つなぎにする。

inorderの解説
- https://github.com/fuga-98/arai60/pull/29#discussion_r2020242408
- https://github.com/tarinaihitori/leetcode/pull/29#discussion_r2044913447

inorder順にノードを生成するということはあるノードを作成した時点で左部分木のノードは全部作成済み
問題は、「生成済みのノードのうち、どれが自分の左部分木に属するか？」 => 作成はされているけど宙ぶらりんの状態

- 長いが自分の理解: `node`を今走査しているとすると、inorder順に操作するとnodeの左部分木になるものは、すでに出ている。左部分木の集合は、preorderをnode.valで特定して、それよりindexが大きい位置に出てくるものなので、インデックスが大きい位置にあるノードはすべて同じ左部分木に属する。あとはその左部分木を構築して`node`のleftに渡してやればいい。その構築もinorderで左部分木を構築してきたならば、左部分木の左の子に関しては構築済みなのでstackに入っているノードの.rightが未確定。だから`while stack`の中では右につけていくのだが、stackは先入れ後出しなので一番最初に出てきたやつが一番右にあるはず。これを考慮するとコードのようになる。
(むずかしい...)
```python
def buildTree(self, preorder, inorder):
    preorder_pos = {val: i for i, val in enumerate(preorder)}
    stack = []

    def gather_descendants(node_position):
        child = None
        while stack:
            if preorder_pos[stack[-1].val] < node_position:
                break
            back = stack.pop()
            back.right = child
            child = back
        return child

    for val in inorder:
        node = TreeNode(val)
        node.left = gather_descendants(preorder_pos[val])
        stack.append(node)

    return gather_descendants(float('-inf'))
```

- [nittoco/leetcode#37 line 345-364](https://github.com/nittoco/leetcode/pull/37#discussion_r1821720967) — stackの不変条件に関する議論

### preorder順に構築するスタックベース解法
- [naoto-iwase/leetcode#34](https://github.com/naoto-iwase/leetcode/pull/34) — 実装2で詳しい解説あり
- [Yoshiki-Iwasa/Arai60#33 step4.rs](https://github.com/Yoshiki-Iwasa/Arai60/pull/33) — Rust実装

### 変数名など
- `val` vs `value`: `node.val`に合わせるなら`val`、一般的には`value`が無難
- `left, right`が何を指すか明確な関数名にすべき
- 内包表記 vs forループ: Pythonに慣れていない人にはforループの方が読みやすい。好みの差

- [fuga-98/arai60#29 line 36](https://github.com/fuga-98/arai60/pull/29) — val vs value
- [tarinaihitori/leetcode#29 line 40](https://github.com/tarinaihitori/leetcode/pull/29) — left, rightの関数名


### 再帰のスタックサイズ計算
再帰のスタック使用量を手計算：
- 1フレームあたり約88byte（引数16byte + 関数内48byte + TreeNode 24byte）
- 3000ノード × 88byte = 264KB、スタックサイズ2MiBに収まるのでOK

- Pythonだと再帰回数で制限している

- [Yoshiki-Iwasa/Arai60#33 step1.rs](https://github.com/Yoshiki-Iwasa/Arai60/pull/33)

### NamedTupleやdataclassの活用
タプルで複数の値をまとめると役割が分かりにくい。`NamedTuple`や`@dataclass(frozen=True)`を使うと型ヒント付きで安心。
- [nittoco/leetcode#37 line 185](https://github.com/nittoco/leetcode/pull/37#discussion_r1821720967)



## Step3
```py
class Solution:
    def buildTree(self, preorder, inorder):
        assert len(preorder) == len(inorder)
        inorder_to_index = {}
        for i in range(len(inorder)):
            inorder_to_index[inorder[i]] = i
    
        def buildSubTree(preorder_start, preorder_end, inorder_start, inorder_end):
            if preorder_start > preorder_end:
                return None

            root_val = preorder[preorder_start]
            root = TreeNode(root_val)
            idx = inorder_to_index[root_val]
            left_size = idx - inorder_start

            root.left = buildSubTree(preorder_start + 1, preorder_start + left_size, inorder_start, idx - 1)
            root.right = buildSubTree(preorder_start + left_size + 1, preorder_end, idx + 1, inorder_end)
            return root

        return buildSubTree(0, len(preorder) - 1, 0, len(inorder) - 1)

```