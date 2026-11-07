#!/usr/bin/env python3
"""Stage on APFS, bundle dependency closure, ad-hoc sign, and archive."""
from pathlib import Path
import subprocess as sp, shutil, tempfile, plistlib, zipfile, json, hashlib
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT
BUILD=ROOT/'build'
OUT=ROOT/'dist'
OUT.mkdir(exist_ok=True)
def run(*a):return sp.check_output(a,text=True,stderr=sp.STDOUT)
def copytree(a,b):shutil.copytree(a,b,ignore=shutil.ignore_patterns('._*','.DS_Store'))
with tempfile.TemporaryDirectory(prefix='ff2-package-') as tmp:
 app=Path(tmp)/'Final Fight 2.app';contents=app/'Contents';mac=contents/'MacOS';res=contents/'Resources';fw=contents/'Frameworks'
 for d in (mac,res,fw):d.mkdir(parents=True)
 shutil.copyfile(BUILD/'FinalFight2SNESRecomp',mac/'ff2-runtime');(mac/'ff2-runtime').chmod(0o755)
 run('clang','-mmacosx-version-min=26.0','-fobjc-arc','-framework','Cocoa',str(SRC/'portable/launcher.m'),'-o',str(mac/'FinalFight2'))
 copytree(BUILD/'assets',res/'assets')
 # This title replaces the LCD/composite looks with two fine scanline profiles.
 shader_dir=res/'assets/shaders'
 for name in ('lcd-grid','warm-composite'):
  for f in (shader_dir/(name+'.glslp'),shader_dir/'_passes'/(name+'-pass.glsl')):
   if f.exists():f.unlink()
 for f in (SRC/'portable/shaders').rglob('*'):
  if f.is_file() and not f.name.startswith('._'):
   dst=shader_dir/f.relative_to(SRC/'portable/shaders')
   dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(f,dst)
 for f in ('config.ini','keybinds.ini'):shutil.copyfile(SRC/'portable'/f,res/f)
 licenses=res/'Licenses';licenses.mkdir();shutil.copyfile(SRC/'snesrecomp/LICENSE',licenses/'snesrecomp.txt')
 # Runtime font assets retain their license files in assets/fonts.
 ui=ROOT/'recomp-ui'
 shutil.copyfile(ui/'LICENSE',licenses/'recomp-ui.txt')
 shutil.copyfile(ui/'src/third_party/imgui/LICENSE.txt',licenses/'Dear-ImGui.txt')
 shutil.copyfile(SRC/'LICENSE',licenses/'FinalFight2SNESRecomp.txt')
 queue=[mac/'ff2-runtime'];copied={};brew=set()
 # SDL2 compatibility loads SDL3 dynamically, so seed that dependency explicitly.
 def bundle(path):
  path=Path(path);name=path.name
  if name not in copied:
   dst=fw/name;shutil.copyfile(path,dst);dst.chmod(0o755);copied[name]=str(path);queue.append(dst)
   run('install_name_tool','-id','@rpath/'+name,str(dst))
   parts=path.parts
   if 'opt' in parts and str(path).startswith('/opt/homebrew/opt/'):brew.add(parts[4])
  return name
 bundle('/opt/homebrew/opt/sdl3/lib/libSDL3.0.dylib')
 # SDL2-compat expects the unversioned SDL3 name at its own loader path.
 (fw/'libSDL3.dylib').symlink_to('libSDL3.0.dylib')
 while queue:
  binary=queue.pop(0)
  deps=[l.strip().split(' (')[0] for l in run('otool','-L',str(binary)).splitlines()[1:]]
  for dep in deps:
   if dep.startswith('/opt/homebrew/'):
    name=bundle(dep)
    replacement=('@executable_path/../Frameworks/' if binary.parent==mac else '@loader_path/')+name
    run('install_name_tool','-change',dep,replacement,str(binary))
 for formula in brew:
  base=Path('/opt/homebrew/opt')/formula
  for f in list(base.glob('LICENSE*'))+list(base.glob('COPYING*')):
   if f.is_file():shutil.copyfile(f,licenses/(formula+'-'+f.name))
 plist={'CFBundleExecutable':'FinalFight2','CFBundleIdentifier':'com.eddykine.finalfight2','CFBundleName':'Final Fight 2','CFBundlePackageType':'APPL','CFBundleShortVersionString':'0.1.1','CFBundleVersion':'20261107','LSMinimumSystemVersion':'26.0','NSHighResolutionCapable':True}
 (contents/'Info.plist').write_bytes(plistlib.dumps(plist))
 for f in list(fw.iterdir())+list(mac.iterdir()):
  if not f.is_symlink():run('codesign','--force','--sign','-',str(f))
 run('codesign','--force','--sign','-',str(app));run('codesign','--verify','--deep','--strict',str(app))
 # Check only system dependencies or bundle-relative paths remain.
 for f in list(mac.iterdir())+[x for x in fw.iterdir() if not x.is_symlink()]:
  assert '/opt/homebrew/' not in run('otool','-L',str(f)),f
 dest=OUT/app.name
 if dest.exists():shutil.rmtree(dest)
 copytree(app,dest)
 archive=OUT/'Final-Fight-2-macOS-AppleSilicon.zip'
 run('ditto','-c','-k','--norsrc','--keepParent',str(app),str(archive))
 if (SRC/'portable/LEEME.txt').exists():
  shutil.copyfile(SRC/'portable/LEEME.txt',OUT/'LEEME.txt')
  with zipfile.ZipFile(archive,'a',compression=zipfile.ZIP_DEFLATED) as z:
   z.write(SRC/'portable/LEEME.txt','LEEME.txt')
 (OUT/'package-manifest.json').write_text(json.dumps({'architecture':'arm64','libraries':copied,'zip_sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),'rom_included':False},indent=2))
 print(dest);print(archive)
