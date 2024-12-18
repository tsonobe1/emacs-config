import os
import re

def sanitize_filename(filename):
    # ファイル名に使用できない文字を置き換え
    return re.sub(r'[<>:"/\\|?*]', '', filename)

def rename_files_in_directory(directory):
    # ディレクトリ内のすべてのファイルを取得
    for filename in os.listdir(directory):
        if filename.endswith(".org") and not filename.startswith(("~", "#")):
            filepath = os.path.join(directory, filename)
            
            # ファイルの内容を読み取る
            try:
                with open(filepath, 'r', encoding='utf-8') as file:
                    content = file.read()
            except UnicodeDecodeError as e:
                print(f"Skipping file '{filename}' due to decoding error: {e}")
                continue

            # `#+title:` を探してタイトルを取得
            title_match = re.search(r'^\#\+title:\s*(.*)', content, re.MULTILINE)
            if title_match:
                title = title_match.group(1).strip()
                title = sanitize_filename(title)  # ファイル名に適した形式に変換

                # 元のタイムスタンプ部分（yyyyMMddhhmmss）を保持
                timestamp = filename[:15]

                # 新しいファイル名を作成
                new_filename = f"{timestamp}{title}.org"
                new_filepath = os.path.join(directory, new_filename)

                # ファイル名を変更
                try:
                    os.rename(filepath, new_filepath)
                    print(f"Renamed '{filename}' to '{new_filename}'")
                except OSError as e:
                    print(f"Error renaming '{filename}' to '{new_filename}': {e}")

# 使用例
directory = '/Users/tsonobe/.emacs.d/org-roam/knowledge'  # メモが保存されているディレクトリのパスを指定してください
rename_files_in_directory(directory)
