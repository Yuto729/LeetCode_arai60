## Step1
同じ文字構成になる単語を分類する問題. 文字構成が同じということは各文字をカウントしてその結果が同じ単語をグループにすれば解けそう. オーソドックスにhashmapを用いて文字の出現をカウントする.
また,文字構成が同じ単語をグループにするためにhashmapを用いる.
hashmapはそのままでは`hashable`(immutable)ではないので,dictのキーにすることができない. そこで,dictの要素から無理やりユニークなハッシュ値を作成してしまえばいいのではと考え,{文字}{出現回数}の列をキーとした.
以下のように実装をしてAccept.
47ms（かなり遅め）. 
時間計算量はO(N*(LlogL)) N:strsの単語数, L:各単語の平均長. 各文字のカウント&ソート処理で, 単語長Lの走査でO(L)であり,dictのソート処理は英小文字に限定すれば最大26種類なので定数時間になるが,一般的なUnicodeを想定して最大O(L*logL)になる.

```py
class Solution:
    def groupAnagrams(self, strs: List[str]) -> List[List[str]]:
        def get_char_freq(word):
            char_to_freq = defaultdict(int)
            for char in word:
                char_to_freq[char] += 1
            
            return dict(sorted(char_to_freq.items()))

        def dict_to_hash(char_to_freq):
            hash = ""
            for char, freq in char_to_freq.items():
                # 文字 + 出現回数
                hash = f"{hash}{char}{str(freq)}"
            
            return hash
    
        wordcount_to_list = defaultdict(list)
        for word in strs:
            char_to_freq = get_char_freq(word)
            wordcount_to_list[dict_to_hash(char_to_freq)].append(word)
        
        return list(wordcount_to_list.values())
```
hashの変換の効率が悪い. hashを毎回連結して代入しているのでこれだと毎回文字列のコピーが発生し,計算量は最悪(L^2)に. `tuple`はimmutableなのでタプルに変換してキーにすれば高速にhash化できる.
他には`frozenset`もimmutableだが追加処理が遅い.
```py
class Solution:
    def groupAnagrams(self, strs: List[str]) -> List[List[str]]:
        def get_char_frequency(word):
            char_to_freq = defaultdict(int)
            for char in word:
                char_to_freq[char] += 1
            
            return char_to_freq

        def dict_to_hashable(char_to_freq):
            return tuple(sorted(char_to_freq.items()))
    
        charcount_to_anagram = defaultdict(list)
        for word in strs:
            char_to_freq = get_char_frequency(word)
            charcount_to_anagram[dict_to_hashable(char_to_freq)].append(word)
        
        return list(charcount_to_anagram.values())
```


Acceptされてから, 文字列自体をソートしてキーにしまえば一意になることに気がついたので実装を変更. (文字列はhashableなのでキーにできる)
時間計算量: O(N*L*logL) N: strs.length, L: strs[i].length
`str()`でL^2かかる？
19ms
```py
class Solution:
    def groupAnagrams(self, strs: List[str]) -> List[List[str]]:
        uniqeword_to_anagrams = defaultdict(list)
        for word in strs:
            uniqeword_to_anagrams["".join(sorted(word))].append(word)
        
        return list(uniqeword_to_anagrams.values())
```

`str`はこの場合だとlist全体を文字列化してしまうので,`join`を使うほうがいい.

```diff
--- uniqueword_to_list[str(sorted(word))].append(word)
+++ uniqueword_to_list["".join(sorted(word))].append(word)
```

## Step2 コード,コメントを読む
https://github.com/azriel1rf/leetcode-prep/pull/4#discussion_r1973077272
>ord からフォローアップの質問でユニコードのコードポイントの話などが想定されます。
>また、入力が、小文字アルファベットでないものが来たときに、どのような振る舞いをするか、どのような振る舞いをするべきかは追加質問が来てもおかしくないでしょう。

`ord`を使った解法でまずは解いてみる. 時間計算量はO(NL), 空間計算量O(NL).
memo: アルファベット小文字のUnicodeポイントは97 ~ 122, 大文字は65 ~ 50らしい
上記のフォローアップ質問について, 大文字ならG ~ Zまでは用意した配列に加算されるが数値が文字列に含まれていた場合範囲外アクセスになる.('9'のコードポイントは57)
```py
class Solution:
    def groupAnagrams(self, strs: List[str]) -> List[List[str]]:
        counter_to_anagrams = defaultdict(list)
        NUM_CHARACTERS = 26
        BASE_UNICODE_POINT = ord('a')

        for word in strs:
            counts = [0] * NUM_CHARACTERS
            for char in word:
                counts[ord(char) - BASE_UNICODE_POINT] += 1
            
            counter_to_anagrams[tuple(counts)].append(word)
        
        return list(counter_to_anagrams.values())
```
- 入力の制約,範囲などは常に先に考えるようにしたい.


## Step3
これが一番シンプルかつ様々な入力に対応できている.
```py
class Solution:
    def groupAnagrams(self, strs: List[str]) -> List[List[str]]:
        uniqeword_to_anagrams = defaultdict(list)
        for word in strs:
            uniqeword_to_anagrams["".join(sorted(word))].append(word)
        
        return list(uniqeword_to_anagrams.values())
```