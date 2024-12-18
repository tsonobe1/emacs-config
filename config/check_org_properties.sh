#!/bin/bash
############################
# how to use
# bash check_org_properties.sh
# you must use "bash"

DIRECTORY="/Users/tsonobe/.emacs.d/org-roam/"
temp_file=$(mktemp)

# ファイルカウンタの初期化
total_files=0
ok_files=0
ng_files=0
ng_files_list=()

# 一時ファイルに find の結果を保存
find "$DIRECTORY" -type f -name "*.org" -print0 > "$temp_file"

# 一時ファイルを読み取りながら処理
while IFS= read -r -d '' FILE; do
  echo "Found file: $FILE"
  total_files=$((total_files + 1))
  HEAD_CONTENT=$(head -n 5 "$FILE")

  if echo "$HEAD_CONTENT" | grep -q ":PROPERTIES:" && \
     echo "$HEAD_CONTENT" | grep -q ":ID:" && \
     echo "$HEAD_CONTENT" | grep -q ":END:"; then
    ok_files=$((ok_files + 1))
  else
    ng_files=$((ng_files + 1))
    ng_files_list+=("$FILE")
  fi
done < "$temp_file"

# 一時ファイルを削除
rm "$temp_file"

# 結果を表示
echo "Total files: $total_files"
echo "OK files: $ok_files"
echo "NG files: $ng_files"

if [ "$ng_files" -gt 0 ]; then
  echo "NG files list:"
  for FILE in "${ng_files_list[@]}"; do
    echo "$FILE"
  done
fi
