import sys, os
from PIL import Image
import plistlib
import ast
from pathlib import Path
sys.path.append(os.path.dirname(os.path.realpath(__file__)) + '/lib/untp/src/untp')
import untp
from PyTexturePacker import Packer
from shutil import copyfile
import shutil

def rmdir(directory):
    if os.path.exists(directory):
        directory = Path(directory)

        for item in directory.iterdir():
            if item.is_dir():
                rmdir(item)
            else:
                item.unlink()
        directory.rmdir()

basePath = os.path.dirname(os.path.realpath(__file__))
os.chdir(basePath)

en_path = basePath + "/patches/magia-en-apk-assets/"
jp_path = basePath + "/build/app/assets/package/"
print("EN Path: " + en_path)
print("JP Path: " + jp_path)

en_assets = {}
jp_assets = {}
for path in Path(en_path).rglob('*.png'):
    en_assets[path.name] = path
for path in Path(jp_path).rglob('*.png'):
    jp_assets[path.name] = path



required_assets = [["quest_image0","quest_image1"],
                   ["data_download0"],
                  ["ef_battle000","ef_battle001"],
                  ["qb_auto_settings0"],
                  ["qb_continue"],
                  ["qb_ef_sp_combo0"],
                  ["qb_help"],
                  ["story_ui_sprites00"],
                  ["toppage_bg_020", "toppage_bg_021"],
                  ["web_ef_magia_lvup0"],
                  ["web_ef_memoria0", "web_ef_memoria1"],
                  ["web_ef_reality_up0"],
                  ["web_ef_strengthening0"],
                  ["qb_menu_top0"]]
ignored_images = ["dl_loading_bar01.png", "qb_menu_top_14.png"]

copyfile(en_path + "/top/toppage_bg_02.ExportJson", jp_path + "/top/toppage_bg_02.ExportJson")
copyfile(en_path + "/memoria/web_ef_memoria.ExportJson", jp_path + "/memoria/web_ef_memoria.ExportJson")

print("Updating AndroidManifest.xml")
path = Path("build/app/AndroidManifest.xml")
text = path.read_text()
text = text.replace("com.aniplex.magireco", "io.kamihama.magiatranslate")
path.write_text(text)

rmdir("build/assets")
Path("build/assets").mkdir(parents=True, exist_ok=True)

for assets in required_assets:
    rmdir("build/assets/work_jp")
    Path("build/assets/work_jp").mkdir(parents=True, exist_ok=True)
    rmdir("build/assets/work_jp_old")
    Path("build/assets/work_jp_old").mkdir(parents=True, exist_ok=True)
    rmdir("build/assets/work_en")
    Path("build/assets/work_en").mkdir(parents=True, exist_ok=True)
    rmdir("build/assets/work_out")
    Path("build/assets/work_out").mkdir(parents=True, exist_ok=True)
    for asset in assets:
        asset_png = asset + ".png"
        jp_asset_plist = str(jp_assets[asset_png])[:-4] + ".plist"
        jp_asset_png = jp_assets[asset_png]
        #print("Working on JP " + jp_asset_plist)

        untp.unpacker(str(jp_asset_plist), image_file = str(jp_asset_png), output_dir = "build/assets/work_jp")
        untp.unpacker(str(jp_asset_plist), image_file = str(jp_asset_png), output_dir = "build/assets/work_jp_old")

    for asset in assets:
        asset_png = asset + ".png"

        if asset_png in en_assets:
            na_asset_plist = str(en_assets[asset_png])[:-4] + ".plist"
            na_asset_png = en_assets[asset_png]
            #print("Working on NA " + na_asset_plist)
            untp.unpacker(str(na_asset_plist), image_file = str(na_asset_png), output_dir = "build/assets/work_en")
            #print("Skipping NA %s" % asset_png)

    for toCopy in Path("build/assets/work_en").rglob("*.*"):
        filename = os.path.basename(str(toCopy))
        #print("Copying %s" % str(toCopy)[8:])
        if (filename not in ignored_images):
            copyfile("build/assets/work_en/" + filename, "build/assets/work_jp/" + filename)

    manualPath = basePath + "patches/images/" + assets[0] + "/"
    if os.path.exists(manualPath):
        print("Adding manual replacements for " + assets[0] + ".")
        for toCopy in Path(manualPath).rglob("*.*"):
            filename = os.path.basename(str(toCopy))
            print("Copying " + filename + "...")
            copyfile(toCopy, "build/assets/work_jp/" + filename)

    if assets[0] == "toppage_bg_020":
        print("Manual override for toppage")
        packer = Packer.create(max_width=2048, max_height=1920, bg_color=0x00ffffff, enable_rotated=False)
    else:
        packer = Packer.create(max_width=2048, max_height=2048, bg_color=0x00ffffff, enable_rotated=False)

    if str(assets[0][-1]) == '0':
        packer.pack("build/assets/work_jp/", str(assets[0][:-1]) + "%d", output_path="build/assets/work_out/")
    else:
        packer.pack("build/assets/work_jp/", str(assets[0]), output_path="build/assets/work_out/")

    for asset in assets:
        asset_png = asset + ".png"
        jp_asset_plist = str(jp_assets[asset_png])[:-4] + ".plist"
        jp_asset_png = jp_assets[asset_png]
        os.remove(jp_asset_png)
        os.remove(jp_asset_plist)
    savedir = os.path.dirname(jp_asset_png)
    print("Saving to %s" % savedir)
    file_names = os.listdir("build/assets/work_out/")

    for file_name in file_names:
        shutil.move(os.path.join("build/assets/work_out/", file_name), savedir)
