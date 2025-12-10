## Step1
2つの配列の共通セットを列挙する問題. setを用いる
以下のアルゴリズムで時間計算量: O(n+m), 空間計算量: O(n+l).l: intersectionの長さ

```py
class Solution:
    def intersection(self, nums1: List[int], nums2: List[int]) -> List[int]:
        if not nums1 or not nums2:
            return []

        seen = set()
        for num in nums1:
            seen.add(num)
        intersection = set()
        for num in nums2:
            if num in seen and num not in intersection:
                intersection.add(num)
        
        return list(intersection)
```
上記のコードを整える.
```py
class Solution:
    def intersection(self, nums1: List[int], nums2: List[int]) -> List[int]:
        if not nums1 or not nums2:
            return []

        seen = set(nums1)
        intersection = set()
        for num in nums2:
            if num in seen:
                intersection.add(num)
        
        return list(intersection)
```
## Step2 他の人のコード・コメント集を読む
https://github.com/docto-rin/leetcode/pull/13/
参考に,以下のように最適化する.
- イテレーションするのは長さが短い方のset

上記のようにすることでどちらかのsetが極端に長い場合やnums1の重複が非常に多い場合に効率化できそう.
setの構築はO(n)（最悪のケースでO(n^2)になるそう. 後に考察する）
以下のプログラムの時間計算量はO(n + m).

Q. setを余計に一つ作成しているが, setの構築コストの影響は？
```py
class Solution:
    def intersection(self, nums1: List[int], nums2: List[int]) -> List[int]:
        set1 = set(nums1)
        set2= set(nums2)
        if len(set1) > len(set2):
            set1, set2 = set2, set1

        intersection = []
        for num in set1:
            if num in set2:
                intersection.append(num)
        
        return intersection
```

https://github.com/katataku/leetcode/pull/12#discussion_r1893968021
>片方がとても大きくて、片方がとても小さいときには、大きい方を set にするのは大変じゃないでしょうか、特に大きいほう
>が sort 済みのときにはどうしますか。

小さい方をsetにし, 大きいほうでイテレーションをすることで以下の問題を解決できる.
- 大きいリストの場合それをsetにするのはコストが大きい場合がある. setは内部的にはハッシュテーブルを用いて実装されているので,大きい集合に対してはそれだけハッシュの衝突&リサイズが起きる. => setの構築の実装について見てみよう.

```py
class Solution:
    def intersection(self, nums1: List[int], nums2: List[int]) -> List[int]:
        if len(nums1) > len(nums2):
            nums1, nums2 = nums2, nums1

        seen = set(nums1)
        intersection = set()
        for num in nums2:
            if num in seen:
                intersection.add(num)
        
        return list(intersection)
```
一方, 長いほうがソートされている場合, 長い方のリストをイテレーションするより二分探索で見つけるほうが良い.
時間計算量: O(m*logm + n*logm). m > n
```py
class Solution:
    def intersection(self, nums1: List[int], nums2: List[int]) -> List[int]:
        def binary_search(nums, target):
            left = 0
            right = len(nums) - 1
            while left <= right:
                mid = (left + right) // 2
                if nums[mid] < target:
                    left = mid + 1
                    continue
                if nums[mid] > target:
                    right = mid - 1
                    continue
  
                return True
            
            return False
        
        if len(nums1) > len(nums2):
            nums1, nums2 = nums2, nums1
        
        nums2.sort()
        intersection = set()
        for num in nums1:
            if (binary_search(nums2, num)):
                intersection.add(num)
        
        return list(intersection)
```
https://github.com/katataku/leetcode/pull/12#discussion_r1894613102
>他、両方ソートされていてとても大きければ、マージソートの変形のように書くと思います.

これは次のようなtwo pointerを用いた解法だと思われるので実装してみる.(ref.https://discord.com/channels/1084280443945353267/1183683738635346001/1188897668827730010)
時間計算量O(nlogn + mlogm)
```py
class Solution:
    def intersection(self, nums1: List[int], nums2: List[int]) -> List[int]:
        nums1.sort()
        nums2.sort()

        i, j = 0, 0
        intersection = []
        while i < len(nums1) and j < len(nums2):
            if nums1[i] < nums2[j]:
                i += 1
                continue

            if nums2[j] < nums1[i]:
                j += 1
                continue
            common = nums1[i]
            intersection.append(common)
            # commonと等しくなくなるまでポインターを飛ばす
            while i < len(nums1) and nums1[i] == common:
                i += 1
            while j < len(nums2) and nums2[j] == common:
                j += 1
        
        return list(intersection)
```

他に, 以下のようにsetの`intersection`メソッドを用いると最も簡潔に記述できる.
```py
class Solution:
    def intersection(self, nums1: List[int], nums2: List[int]) -> List[int]:
        nums1_set = set(nums1)
        nums2_set = set(nums2)
        # nums1_set.intersection(nums2_set)と同じ
        return list(nums1_set & nums2_set)
```
## Step3
マージソート風回答で練習
```py
class Solution:
    def intersection(self, nums1: List[int], nums2: List[int]) -> List[int]:
        if not nums1 or not nums2:
            return []
        
        nums1.sort()
        nums2.sort()
        i, j = 0, 0
        intersection = set()
        last = None

        while i < len(nums1) and j < len(nums2):
            if nums1[i] < nums2[j]:
                i += 1
                continue
            
            if nums1[i] > nums2[j]:
                j += 1
                continue

            common = nums1[i]
            intersection.add(common)
            while i < len(nums1) and nums1[i] == common:
                i += 1
                continue
            
            while j < len(nums2) and nums2[j] == common:
                j += 1
                continue   
        
        return list(intersection)
```

## メモ
setの構築ってそもそもどんな実装か
https://docs.python.org/ja/3.10/c-api/set.html

- オープンアドレッシングを用いる．
以下がセットに要素を追加するコアな関数
- input: セットオブジェクト, key, hash値
- 初期位置の計算: hash値をテーブルサイズで割った位置
- while do文内でハッシュが衝突するかしないかを判断. 衝突しない場合は`go to`でループを抜ける. 衝突した場合は`probes`が0になるまで連続したスロットを調べる.
- `probes`が0になっても衝突する場合, 再ハッシュして新しい場所を探す.
- 空きスロットがない場合, リサイズをする. リサイズはテーブルの60%が埋まったらされるっぽい. リサイズの際は全エントリでハッシュ値を計算し直す.

setの挿入はO(1)と略されるが, バケットの占有率が上がってくると参照, 削除の効率が加速度的に低下するのでコストが上がりすぎないところでリサイズが必要なのだと思われる.
```c
set_add_entry_takeref(PySetObject *so, PyObject *key, Py_hash_t hash)
{
    setentry *table;
    setentry *freeslot;
    setentry *entry;
    size_t perturb;
    size_t mask;
    size_t i;                       /* Unsigned for defined overflow behavior */
    int probes;
    int cmp;

  restart:
    
    /* 初期位置の計算 */ 
    mask = so->mask;
    /* hash % table_sizeと同じ計算. ビット演算は1クロックでできるので高速. 
    普通の除算は2桁クロックかかるらしい.*/
	  i = (size_t)hash & mask;
	  /* 削除済みスロットのアドレスを一時的に記録する*/
    freeslot = NULL;
    perturb = hash;

    while (1) {
        entry = &so->table[i];
        probes = (i + LINEAR_PROBES <= mask) ? LINEAR_PROBES: 0;
        do {
            if (entry->hash == 0 && entry->key == NULL)
            　　 /* hash=0は空であることを意味する.*/
                goto found_unused_or_dummy;
            if (entry->hash == hash) {
                PyObject *startkey = entry->key;
                assert(startkey != dummy);
                if (startkey == key)
		                /* 同一オブジェクトであるとき, setには追加しない */
                    goto found_active;
                if (PyUnicode_CheckExact(startkey)
                    && PyUnicode_CheckExact(key)
                    && unicode_eq(startkey, key))
                    /* 両方文字列のとき */
                    goto found_active;
                table = so->table;
                Py_INCREF(startkey);
                
                /* 上記以外のとき, __eq__メソッドを呼んで比較する. 遅め*/
                cmp = PyObject_RichCompareBool(startkey, key, Py_EQ);
                Py_DECREF(startkey);
                if (cmp > 0)
                    goto found_active;
                if (cmp < 0)
                    goto comparison_error;
                if (table != so->table || entry->key != startkey)
                    goto restart;
                mask = so->mask;
            }
            else if (entry->hash == -1) {
		            /* hash = -1は削除済みであることを表す.*/
                assert (entry->key == dummy);
                freeslot = entry;
            }
            /* 衝突したとき: 連続したスロットを調べる. */
            entry++;
        } while (probes--);
        
        /* 再ハッシュして新しい位置に移動 */
        perturb >>= PERTURB_SHIFT;
        i = (i * 5 + 1 + perturb) & mask;
    }

  found_unused_or_dummy:
    if (freeslot == NULL)
        goto found_unused;
    FT_ATOMIC_STORE_SSIZE_RELAXED(so->used, so->used + 1);
    /* 削除済みスロットがあれば利用 */
    freeslot->key = key;
    freeslot->hash = hash;
    return 0;

  found_unused:
    so->fill++;
    FT_ATOMIC_STORE_SSIZE_RELAXED(so->used, so->used + 1);
    entry->key = key;
    entry->hash = hash;
    if ((size_t)so->fill*5 < mask*3)
        return 0;
    return set_table_resize(so, so->used>50000 ? so->used*2 : so->used*4);

  found_active:
    /* https://docs.python.org/ja/3.10/c-api/refcounting.html?highlight=py_decref#c.Py_DECREF
    keyオブジェクトの参照カウンタを減らす. 
    */
    Py_DECREF(key);
    return 0;

  comparison_error:
    Py_DECREF(key);
    return -1;
}
```
setを使うことが必ずしも最適ではないことがわかった. ハッシュの衝突, リサイズなどの定数オーダーの処理のコストも考えることが大切.
