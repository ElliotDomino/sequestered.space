import os
import re
import json
import argparse
import markdown
import frontmatter
from datetime import datetime

# --- PATH CONFIGURATION ---
# The Generator folder is where your content lives
GENERATOR_DIR = os.path.dirname(os.path.abspath(__file__))
CONTENT_DIR = os.path.join(GENERATOR_DIR, "content")

# The Site folder is where the generated files and resources live
PROJECT_ROOT = os.path.dirname(GENERATOR_DIR)
SITE_DIR = os.path.join(PROJECT_ROOT, "sequestered.space")
ARTICLES_DIR = os.path.join(SITE_DIR, "articles")
RESOURCES_DIR = os.path.join(SITE_DIR, "resources")

# Ensure target directories exist
os.makedirs(CONTENT_DIR, exist_ok=True)
os.makedirs(ARTICLES_DIR, exist_ok=True)
os.makedirs(RESOURCES_DIR, exist_ok=True)

ARTICLE_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} // SEQUESTERED.SPACE</title>
    <link rel="icon" href="/resources/soul-white-small.ico" type="image/x-icon">
    <style>
        :root {{ --bg: #000; --fg: #fff; --accent: #00f5ff; --highlight: #ffaa00; --border: #333; }}
        ::selection {{ background: var(--highlight); color: #000; }}
        body, html {{ background: var(--bg); color: var(--fg); font-family: 'Courier New', monospace; margin: 0; padding: 0; line-height: 1.6; }}
        .container {{ max-width: 800px; margin: 0 auto; padding: 40px 20px; }}
        header {{ border-bottom: 2px solid var(--accent); margin-bottom: 40px; padding-bottom: 20px; position: relative; }}
        header::after {{ content: ""; position: absolute; bottom: -5px; left: 0; width: 80px; height: 2px; background: var(--highlight); }}
        .header-top {{ display: flex; justify-content: space-between; align-items: center; gap: 16px; flex-wrap: wrap; }}
        .index-pill {{ background: var(--accent); color: #000; padding: 2px 8px; font-weight: bold; margin-right: 10px; }}
        .archive-link {{ color: var(--highlight); font-weight: bold; border: 1px solid var(--highlight); padding: 8px 12px; letter-spacing: 0.08em; text-transform: uppercase; }}
        .archive-link:hover {{ background: var(--highlight); color: #000; text-decoration: none; }}
        h1 {{ font-size: clamp(1.5rem, 5vw, 2.5rem); margin: 10px 0; text-transform: uppercase; color: var(--fg); }}
        .meta-bar {{ display: flex; gap: 20px; font-size: 0.8rem; color: var(--accent); text-transform: uppercase; border-top: 1px solid var(--border); border-bottom: 1px solid var(--border); padding: 5px 0; margin-top: 20px; }}
        .meta-bar span:first-child {{ color: var(--highlight); font-weight: bold; }}
        .content {{ font-size: 1.1rem; }}
        .content h2 {{ border-left: 5px solid var(--accent); padding-left: 15px; margin-top: 40px; text-transform: uppercase; font-size: 1.2rem; color: var(--accent); }}
        .content strong {{ color: var(--highlight); font-weight: bold; }}
        .content blockquote {{ border-left: 3px solid var(--highlight); margin: 20px 0; padding: 10px 20px; background: rgba(255, 170, 0, 0.05); color: var(--highlight); font-style: italic; }}
        .content img,
        .content video,
        .content iframe,
        .content canvas,
        .content svg {{ display: block; max-width: 100%; width: 100%; height: auto; margin: 20px 0; }}
        .content img,
        .content video,
        .content iframe,
        .content canvas {{ border: 1px solid var(--accent); }}
        .thought-log {{ background: rgba(255, 170, 0, 0.1); border: 1px solid var(--highlight); padding: 20px; margin: 40px 0; position: relative; }}
        .thought-log::before {{ content: "THOUGHT_LOG // OBSERVATION"; position: absolute; top: -10px; left: 10px; background: var(--highlight); color: #000; font-size: 0.7rem; padding: 2px 5px; font-weight: bold; }}
        footer {{ margin-top: 80px; border-top: 1px solid var(--border); padding-top: 20px; font-size: 0.8rem; color: var(--border); display: flex; justify-content: space-between; align-items: center; gap: 16px; flex-wrap: wrap; }}
        a {{ color: var(--accent); text-decoration: none; }}
        a:hover {{ text-decoration: underline; color: var(--highlight); }}
        pre {{ background: #111; padding: 15px; border: 1px solid var(--border); overflow-x: auto; border-left: 3px solid var(--highlight); }}
        code {{ color: var(--highlight); }}
        @media (max-width: 640px) {{
            .header-top {{ align-items: flex-start; }}
            .archive-link {{ width: 100%; box-sizing: border-box; text-align: center; }}
            footer {{ align-items: flex-start; }}
        }}
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="header-top">
                <div><span class="index-pill">{index}</span> / PROJECTS</div>
                <a class="archive-link" href="../../index.html">GO_BACK_TO_ARCHIVE</a>
            </div>
            <h1>{title}</h1>
            <div class="meta-bar"><span>STATUS: {status}</span><span>DATE: {date}</span></div>
        </header>
        <article class="content">{content}</article>
        <div class="thought-log">{thought}</div>
        <footer>
            <span>[EOF] SEQUESTERED.SPACE // 2026</span>
            <a class="archive-link" href="../../index.html">GO_BACK_TO_ARCHIVE</a>
        </footer>
    </div>
</body>
</html>
"""


def normalize_article_paths(markdown_text, folder_name):
    article_resource_prefix = f"articles/{folder_name}/resources/"

    markdown_text = re.sub(
        r'(\[[^\]]*\]\()\/projects\/[^\/)]+\/([^\/)]+\))',
        lambda match: f"{match.group(1)}./resources/{match.group(2)}",
        markdown_text,
    )
    markdown_text = re.sub(
        r'(\[[^\]]*\]\()https:\/\/sequestered\.space\/projects\/[^\/)]+\/([^\/)]+\))',
        lambda match: f"{match.group(1)}./resources/{match.group(2)}",
        markdown_text,
    )
    markdown_text = markdown_text.replace(
        f"https://sequestered.space/{article_resource_prefix}",
        "./resources/",
    )
    markdown_text = markdown_text.replace(
        f"/{article_resource_prefix}",
        "./resources/",
    )
    markdown_text = markdown_text.replace(
        article_resource_prefix,
        "./resources/",
    )
    return markdown_text


def force_non_landing_links_to_new_tab(html):
    return re.sub(
        r'<a(?![^>]*\btarget=)([^>]*\bhref="(?!\.\./\.\./index\.html)[^"]+"[^>]*)>',
        r'<a\1 target="_blank" rel="noopener noreferrer">',
        html,
    )


def extract_preview_assets(normalized_content, folder_name):
    previews = []

    video_sources = re.findall(
        r'<source[^>]+src=["\'](.*?)["\']',
        normalized_content,
        flags=re.IGNORECASE,
    )
    video_sources.extend(
        re.findall(
            r'<video[^>]+src=["\'](.*?)["\']',
            normalized_content,
            flags=re.IGNORECASE,
        )
    )

    image_sources = re.findall(r'!\[.*?\]\((.*?)\)', normalized_content)

    def to_article_path(asset_path):
        if asset_path.startswith('http'):
            return asset_path
        normalized_path = asset_path[2:] if asset_path.startswith("./") else asset_path
        return f"articles/{folder_name}/{normalized_path}"

    for src in video_sources + image_sources:
        resolved = to_article_path(src)
        if resolved not in previews:
            previews.append(resolved)

    return previews

def build(overwrite_existing=False):
    if not os.path.exists(CONTENT_DIR):
        print(f"Error: Content directory {CONTENT_DIR} not found.")
        return

    projects = []
    md_files = sorted([f for f in os.listdir(CONTENT_DIR) if f.endswith('.md')])
    posts = []

    for i, filename in enumerate(md_files, 1):
        post = frontmatter.load(os.path.join(CONTENT_DIR, filename))
        raw_index = post.get('index')
        if raw_index is None:
            sort_index = i
            index_str = f"{i:03d}"
        else:
            index_str = str(raw_index).zfill(3)
            sort_index = int(index_str)

        posts.append((sort_index, filename, post, index_str))

    for _, filename, post, index_str in sorted(posts, key=lambda item: (item[0], item[1])):
        slug = post.get('slug', filename.replace('.md', '').lower())
        folder_name = f"{index_str}-{slug.upper()}"
        
        article_dir = os.path.join(ARTICLES_DIR, folder_name)
        os.makedirs(article_dir, exist_ok=True)
        article_index_path = os.path.join(article_dir, "index.html")

        normalized_content = normalize_article_paths(post.content, folder_name)
        html_content = force_non_landing_links_to_new_tab(
            markdown.markdown(normalized_content)
        )
        article_html = ARTICLE_TEMPLATE.format(
            title=post.get('title', 'Untitled'),
            index=index_str,
            status=post.get('status', 'DRAFT').upper(),
            date=post.get('date', datetime.now().strftime('%Y.%m.%d')),
            content=html_content,
            thought=post.get('thought', 'Observation sequestered.')
        )

        if os.path.exists(article_index_path) and not overwrite_existing:
            print(f"Skipped existing article: {folder_name}")
        else:
            with open(article_index_path, 'w') as f:
                f.write(article_html)
            print(f"Built: {folder_name}")

        # Extract images for the landing page manifest
        previews = extract_preview_assets(normalized_content, folder_name)

        projects.append({
            "index": index_str,
            "title": post.get('title', 'Untitled'),
            "category": post.get('category', 'PROJ'),
            "url": f"articles/{folder_name}/index.html",
            "previews": previews
        })

    # Generate the projects manifest in the site's resources folder
    manifest_path = os.path.join(RESOURCES_DIR, "projects.json")
    with open(manifest_path, "w") as f:
        json.dump(projects, f, indent=2)
    print(f"Generated: {manifest_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--overwrite-existing",
        action="store_true",
        help="Regenerate article HTML even when the destination already exists.",
    )
    args = parser.parse_args()
    build(overwrite_existing=args.overwrite_existing)
