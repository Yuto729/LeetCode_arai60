## Step1

47ms
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
                hash = f"{hash}{char}{str(freq)}"
            
            return hash
    
        wordcount_to_list = defaultdict(list)
        for word in strs:
            char_to_freq = get_char_freq(word)
            wordcount_to_list[dict_to_hash(char_to_freq)].append(word)
        
        return list(wordcount_to_list.values())
```
上記はhashableにすればいいので単純にtupleに変換するとか.


一回Acceptされてから, 文字列自体をソートしてキーにしまえば一意になることに気がついたので実装を変更.
時間計算量: O(n*m*logm) n: strs.length, m: strs[i].length
19ms
```py
class Solution:
    def groupAnagrams(self, strs: List[str]) -> List[List[str]]:
        uniqueword_to_list = defaultdict(list)
        for word in strs:
            uniqueword_to_list[str(sorted(word))].append(word)
        
        return list(uniqueword_to_list.values())
```

以下の操作で平均的にRuntimeが改善した. なんで？
```diff
--- uniqueword_to_list[str(sorted(word))].append(word)
+++ uniqueword_to_list["".join(sorted(word))].append(word)
```