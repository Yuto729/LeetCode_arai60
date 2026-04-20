## Step1
sの長さは10^4 => N^2だと遅い. O(N)で解けると良さそう.
直感的には, スライディングウィンドウを使って各ウィンドウ内にある文字がユニークになるようにしていけば良さそうだとわかった.
現在のウィンドウの中に文字があるかどうか => 辞書かsetでO(1)で判断できる.
このような考えのもと以下のようなコードを書いたがクリアできず断念.
```py
class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        current_window = {}

        left = 0
        right = 0
        max_length = 0
        while left <= right < len(s):
            if s[right] in current_window:
                # ここでmaxを更新すると文字数が1の入力でうまくいかない. 
                if right - left > max_length:
                    max_length = right - left
                
                index_of_same_char = current_window[s[right]]
                left = index_of_same_char + 1

                # 厳密にはここで重複がなくなるまでスライドさせないといけないから初期化してはいけない.
                # left以下のインデックスをdictから消したいけどそれは難しい.
                current_window = {}
                
            else:
                current_window[s[right]] = right
                right += 1
            
        return max_length

```


一旦解答を見てみる.
https://leetcode.com/problems/longest-substring-without-repeating-characters/solutions/5111376/video-3-ways-to-solve-this-question-slid-uupi


```py
class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        # setを用いる.
        last_seen_char = set()

        left = 0
        right = 0
        max_length = 0
        while right < len(s):
            if s[right] in last_seen_char:  
                # 重複が発生したら, 一番左の文字をwindowから外していく.
                last_seen_char.remove(s[left])
                left += 1

            else:
                max_length = max(max_length, right - left + 1)
                last_seen_char.add(s[right])
                right += 1
            
        return max_length
```

## Step2

refs. https://github.com/olsen-blue/Arai60/pull/49/files, https://github.com/docto-rin/leetcode/pull/49/files

１つ目の失敗した解法と同じように**dict**を使う方法.
上記の解法を参考にした.
```py
class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        char_to_index = {}

        left = 0
        right = 0
        max_length = 0
        while right < len(s): # ここは普通にforで良かった....
            """
            s[right]がキーとして存在 & valueがleftより大きいという条件で考えれば,
            dictからleft以下のインデックスを消す必要がなくなる.
            
            上記解法の中には, left = max(left, char_to_index[s[right]] + 1)としているものもあったが, if文で予めleft以上かどうかを判定するほうが, 直感的にわかりやすい.
            """

            if (idx := char_to_index.get(s[right], -1)) >= left:
                left = idx + 1
                left = char_to_index[s[right]] + 1

            max_length = max(max_length, right - left + 1)
            char_to_index[s[right]] = right
            right += 1
    
        return max_length
```


## Step3
setを使うやつ.

```py
class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        last_seen_char = set()
        
        left = 0
        right = 0
        max_length = 0

        while right < len(s):
            if s[right] in last_seen_char:
                last_seen_char.remove(s[left])
                left += 1

            else:
                last_seen_char.add(s[right])
                max_length = max(max_length, right - left + 1)
                right += 1
        
        return max_length
```
