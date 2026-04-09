## Step1
なんかLRUっぽいなと思いつつLRUのような実装は思いつかないので正攻法で.
文字をキーとしてValueにインデックスをリストでつなげていけば良さそう. 丁寧に場合分けを書いてAccept.
計算量: O(n)

```py
class Solution:
    def firstUniqChar(self, s: str) -> int:
        if not s:
            return -1
        
        char_to_indices = defaultdict(list)
        for i, c in enumerate(s):
            char_to_indices[c].append(i)
        
        first_index = -1
        for c, index_list in char_to_indices.items():
            if len(index_list) > 1:
                continue
            
            if len(index_list) == 0:
                continue
            
            if first_index == -1:
                first_index = index_list[0]
                continue

            first_index = min(first_index, index_list[0])
            
        return first_index
```

簡略化
```py
class Solution:
    def firstUniqChar(self, s: str) -> int:
        char_to_count = defaultdict(int)
        for c in s:
            char_to_count[c] += 1

        for i, c in enumerate(s):
            if char_to_count[c] == 1:
                return i
        
        return -1
```

## Step2 他の人のコード・コメントを読む
LRUライク

1-passでできるか（想定ケース: 文字列がストリーミングで流れてきた場合に1回見るだけで済ませたい）

https://discord.com/channels/1084280443945353267/1233603535862628432/1238208008182562927
文字列を二回走査するとしたらStep1の手法でいいが, 1回しか走査しないとしたらループ間で何を引き継いだらいいか？
=> すでに出た文字を格納するオブジェクトと1回しか出てきていない文字とそのインデックスを格納したオブジェクトがあれば判断できそう.

計算量: O(n)
```py
class Solution:
    def firstUniqChar(self, s: str) -> int:
        # すでに登場した文字を格納する
        seen = set()
        # 文字とインデックスを管理するDict
        char_to_index = OrderedDict()
        for i, c in enumerate(s):
            if c in seen:
                if c in char_to_index:
                    del char_to_index[c]
                continue
            
            char_to_index[c] = i
            seen.add(c)

        if char_to_index:
            # list(char_to_index.values())[0]でも良いが以下のように書くとポインタを進めるだけになる.
            return next(iter(char_to_index.values()))

        return -1
```
以上の実装では`OrderedDict`を用いた. `OrderedDict`はhashtableと双方向LinkedListを用いたデータ構造で, hashtableにはキーとLinkedListへのポインタを格納している. 挿入された順序はLinkedListで管理している.

以下参考：Python3.7から辞書の追加順序が保存されるらしいので`OrderedDict`は使わなくて良さそう.
https://discord.com/channels/1084280443945353267/1195700948786491403/1231538588529852426

想定フォローアップ質問
1. ストリーミングで流れてくる場合 => 1passの解法
2. k番目のユニーク文字を返す => 上記の実装でk回nextで進める.

1passを実装するにあたって文字をキューに入れて2回以上出現する文字を取り除いていくやり方もある
https://github.com/colorbox/leetcode/pull/29/changes/BASE..48f2749be9c4ec78c6f24c887880e34c7206f678#r1861430039

## Step3
1passで解く

```py
class Solution:
    def firstUniqChar(self, s: str) -> int:
        char_to_index = {}
        seen = set()
        for i, c in enumerate(s):
            if c in char_to_index:
                del char_to_index[c]
                continue
                
            if c in seen:
                continue

            char_to_index[c] = i
            seen.add(c)
        if char_to_index:
            return next(iter(char_to_index.values()))

        return -1
```