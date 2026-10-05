# dump QNX IFS images, extract file to zip and metadata in json
# jul 2024
# only lzo compression

from struct import Struct
from collections import namedtuple
from binascii import unhexlify, hexlify
import argparse
import json
import sys
import os.path
from hashlib import md5
#from zlib import adler32, crc32
#from ctypes import c_long, c_ulong
import zipfile

import lzo # https://github.com/jd-boyd/python-lzo

#see also: https://github.com/vocho/openqnx/blob/cc95df3543a1c481d4f8ad387e29f0d1ff0c87fe/trunk/utils/m/mkxfs/mkxfs/mk_image_fsys.c#L81

class qifs:

  '''
  find startup header, parse it
  decompresses lzo image and parse it 

  fills self.ifs, a dict will all metadata
  '''
  def __init__(self, filename, quiet=False, verbose=False):

    with open(filename, 'rb') as ifs_file:
      self.ifs_data = ifs_file.read()
      startup_offset = self.ifs_data.find( qifs.IFS_SIGNATURE ) 
      if startup_offset < 0:
        print('no startup header found')
        sys.exit()
  
    self.ifs = dict()
  
    if not quiet:
      print('%8s %8s %8s %-8s' % ('Offset', 'Size', 'Entry', 'Name') )

    startup = self.parse_startup_header( self.ifs_data[ startup_offset: ], startup_offset, quiet, verbose )
    self.ifs['startup_header'] = startup
    self.ifs['startup_header']['offset'] = startup_offset
  
    #print( 'startup sum %x' % c_ulong( ~self.chksum( self.ifs_data[startup_offset: startup_offset+ifs['startup_header']['startup_size']] ) ).value ) #tentative for startup checksum
    
    if startup['compression_type'] == qifs.STARTUP_HDR_FLAGS1_COMPRESS_LZO:
      #print('[+] decompressing image (lzo)...' ) 
      self.decomp_image, compr_size, ptr = self.decomp_lzo_image( startup_offset + startup['startup_size'] )

      #print( 'image sum %x' % c_ulong( ~self.chksum( self.ifs_data[startup_offset + startup_hdr.startup_size:startup_offset + startup_hdr.startup_size] ) ).value ) #tentative for image checksum
        
      image = self.parse_image( quiet )
      self.ifs['image'] = image
    else:
      print( 'unknown compression 0x%x' % startup['compression_type'] ) 


  '''
  decompress lzo image stored in self.ifs_data, at offset ptr
  returns decompressed image, compressed len and ptr/offset after decompression
  '''
  def decomp_lzo_image(self, ptr):
    outlen = 65536
    decomp_image = b''
    compr_size = 0

    compressed_len = Struct('>H').unpack_from( self.ifs_data, ptr )[0] #len of compressed chunk
    ptr += Struct('>H').size
    while compressed_len > 0:
      compr_size += compressed_len
      decompressed = lzo.decompress( self.ifs_data[ ptr:ptr+compressed_len ], False, outlen )
      decomp_image += decompressed
      ptr += compressed_len
      compressed_len = Struct('>H').unpack_from( self.ifs_data, ptr )[0] #len of compressed chunk
      ptr += Struct('>H').size
    return decomp_image, compr_size, ptr


  #https://github.com/askac/dumpifs/blob/master/sys/startup.h
  IFS_SIGNATURE = unhexlify(b'EB7EFF00')
  S_STARTUP_HEADER = Struct('<LHBBHHLLLLLLLLLH6sL')

  '''
  0  4 signature
  4  H version == 1
  6  B flags1
  7  B flags2
  8  H header_size
  A  H machine
  C  L startup_vaddr
  10 L paddr_bias
  14 L image_paddr
  18 L ram_paddr
  1C L ram_size
  20 L startup_size
  24 L stored_size
  28 L imagefs_paddr
  2C L imagefs_size
  30 H preboot_size
  32 ...
  38 L addr_off
  '''
  NT_STARTUP_HEADER = namedtuple('startup_hdr', 'sign version flags1 flags2 header_size machine startup_vaddr paddr_bias image_paddr ram_paddr ram_size startup_size stored_size imagefs_paddr imagefs_size preboot_size unk addr_off')
  S_STARTUP_TRAILER = Struct('<L')

  STARTUP_HDR_FLAGS1_COMPRESS_MASK  = 7
  STARTUP_HDR_FLAGS1_COMPRESS_LZO = 2
  STARTUP_HDR_FLAGS1_COMPRESS_SHIFT = 2

  STARTUP_HEADER_SIZE = 0x100

  '''
  parse startup_header starting ifs_data[startup_offset:] 
  '''
  def parse_startup_header( self, ifs_data, startup_offset, quiet=False, verbose=False ):  
  
    startup_hdr = qifs.NT_STARTUP_HEADER( *qifs.S_STARTUP_HEADER.unpack_from( ifs_data, 0 ) )
    #print(startup_hdr)
    
    startup = dict()
    startup['checksum'] = Struct('<L').unpack_from( ifs_data, startup_hdr.startup_size -4)[0]
    startup['flags1_raw'] = startup_hdr.flags1
    startup['flags2_raw'] = startup_hdr.flags2
    startup['paddr_bias'] = startup_hdr.paddr_bias
    compression = ( startup_hdr.flags1 >> qifs.STARTUP_HDR_FLAGS1_COMPRESS_SHIFT ) & qifs.STARTUP_HDR_FLAGS1_COMPRESS_MASK
    startup['compression_type'] = compression #0=none, 1=zlib, 2=lzo, 3=ucl
  
    startup['flags1'] = list()
    if compression <= 3:
      startup['flags1'].append( qifs.compression_name[compression] )
    else:  
      print('unknown compression!')

    if startup_hdr.flags1 & 1:
      startup['flags1'].append( 'virtual' )
    else:  
      startup['flags1'].append( 'physical' )

    if startup_hdr.flags1 & 2:
      startup['flags1'].append( 'big-endian' )
    else:  
      startup['flags1'].append( 'little-endian' )

    if not quiet:
      print('%8x %8x %8s Startup-header flags1=%x flags2=%s paddr_bias=%x' % (startup_offset , qifs.STARTUP_HEADER_SIZE, '----', startup_hdr.flags1, startup_hdr.flags2, startup_hdr.paddr_bias) )

    if verbose:
      print( '%26s' % '', startup['flags1'] )
      print('%27spreboot_size=0x%x' % ('', startup_hdr.preboot_size) )
      print('%27simage_paddr=0x%x, stored_size=0x%x' % ('', startup_hdr.image_paddr+startup_hdr.addr_off, startup_hdr.stored_size) )
      print('%27sstartup_size=0x%x, imagefs_size=0x%x' % ('', startup_hdr.startup_size, startup_hdr.imagefs_size) )
      print('%27sram_paddr=0x%x, ram_size=0x%x' %  ('', startup_hdr.ram_paddr+startup_hdr.addr_off, startup_hdr.ram_size) )
      print('%27sstartup_vaddr=0x%x' %  ('', startup_hdr.startup_vaddr+startup_hdr.addr_off) )
      print('%27saddr_off=0x%x' %  ('', startup_hdr.addr_off) )

    if not quiet:
      print('%8x %8x %8x startup.*' % (startup_offset+qifs.STARTUP_HEADER_SIZE , startup_hdr.startup_size, startup_hdr.startup_vaddr+startup_hdr.addr_off) )

    startup['preboot_size'] = startup_hdr.preboot_size
    startup['image_paddr'] = startup_hdr.image_paddr+startup_hdr.addr_off
    startup['stored_size'] = startup_hdr.stored_size
    startup['startup_size'] = startup_hdr.startup_size
    startup['imagefs_size'] = startup_hdr.imagefs_size #decompressed size
    startup['ram_paddr'] = startup_hdr.ram_paddr+startup_hdr.addr_off
    startup['ram_size'] = startup_hdr.ram_size
    startup['startup_vaddr'] = startup_hdr.startup_vaddr+startup_hdr.addr_off
    startup['addr_off'] = startup_hdr.addr_off


    compr_size = startup_hdr.stored_size - startup_hdr.startup_size - qifs.S_STARTUP_TRAILER.size
    #print( 'compressed size : 0x%x / %d' % (compr_size, compr_size) )  
  
    return startup



  compression_name = { 0:'none', 1:'zlib', 2:'lzo', 3:'ucl' }

  #https://github.com/askac/dumpifs/blob/master/sys/image.h
  S_IMAGE_HEADER = Struct('<7sBLLL4LLL40sL')
  NT_IMAGE_HEADER = namedtuple('image_header', 'signature flags image_size hdr_dir_size dir_offset boot_ino1 boot_ino2 boot_ino3 boot_ino4 script_ino chain_paddr spare mountflags' )

  S_DIRENT_IMAGE_ATTR = Struct('<HHLLLLL')
  NT_DIRENT_IMAGE_ATTR = namedtuple('dirent_image_attr', 'size extattr_offset ino mode gid uid mtime')

  DIRENT_TYPE_FILE =    0x8000
  DIRENT_TYPE_DIR  =    0x4000
  DIRENT_TYPE_SYMLINK = 0xA000
  DIRENT_TYPE_DEVICE =  0x6000
  DIRENT_TYPE_MASK  =   0xF000
  '''
  parse image header and directory entries
  '''
  def parse_image( self, quiet=False ):
    image_header = qifs.NT_IMAGE_HEADER( *qifs.S_IMAGE_HEADER.unpack_from( self.decomp_image, 0 ) )
    #print( image_header )
    
    end = self.decomp_image[qifs.S_IMAGE_HEADER.size:].find(b'\0')
    mountpoint = self.decomp_image[qifs.S_IMAGE_HEADER.size:qifs.S_IMAGE_HEADER.size+end]
    if not quiet:
      print('%8x %8x %8s Image-header mountpoint=%s' % (0, image_header.dir_offset, '----', mountpoint) )
      print('%8sflags=0x%x, script=%d boot=%d mntflg=%d' % (' '*27, image_header.flags, image_header.script_ino, image_header.boot_ino1, image_header.mountflags) ) 

      print('%8x %8x %8s Image-directory' % (image_header.dir_offset, image_header.hdr_dir_size - image_header.dir_offset, '----') )
    
    image = dict()

    image['mountpoint'] = mountpoint.decode()
    image['flags'] = image_header.flags
    image['script'] = image_header.script_ino
    image['boot'] = image_header.boot_ino1
    image['dir_offset'] = image_header.dir_offset
    image['hdr_dir_size'] = image_header.hdr_dir_size
    image['checksum'] = Struct('<L').unpack_from(self.decomp_image[-4:], 0)[0]
    
    entries = list()
    name_index = dict()
    
    ptr = image_header.dir_offset
    dirent = qifs.NT_DIRENT_IMAGE_ATTR( *qifs.S_DIRENT_IMAGE_ATTR.unpack_from( self.decomp_image, ptr ) )
    while dirent.size > 0:
      #print( 'size=%x mode=%x' % (dirent.size, dirent.mode) )
      _next = ptr+qifs.S_DIRENT_IMAGE_ATTR.size
    
      type = dirent.mode & qifs.DIRENT_TYPE_MASK
      if type == qifs.DIRENT_TYPE_DIR: 
        end = self.decomp_image[_next:].find(b'\0')
        name = self.decomp_image[_next:_next+end]
        if not quiet:
          print('%8x %8s %8s %s' % (_next, '', '----', name) )
      elif type == qifs.DIRENT_TYPE_FILE:
        offset, size = Struct('<LL').unpack_from( self.decomp_image, _next )
        _next += Struct('<LL').size
        end = self.decomp_image[_next:].find(b'\0')
        name = self.decomp_image[_next:_next+end]
        if not quiet:
          print('%8x %8x %8s %s' % (offset, size, '----', name) )
      elif type == qifs.DIRENT_TYPE_SYMLINK: 
        sym_offset, sym_size = Struct('<HH').unpack_from( self.decomp_image, _next )
        _next += Struct('<HH').size
        src = self.decomp_image[_next:_next+sym_offset]
        startd = _next+sym_offset+1
        dst = self.decomp_image[startd:startd+sym_size]
        if not quiet:
          print('%8s %8x %8s %s -> %s' % ('----',sym_size,'----', src.rstrip(b'\0'), dst.rstrip(b'\0')) )
        name = src.rstrip(b'\0')
      elif type == qifs.DIRENT_TYPE_DEVICE: #device 
        print('device, not tested')
        name = 'device'
        
      if not quiet:    
        print('%sgid=%d uid=%d mode=%s ino=%d mtime=%d' % (' '*27, dirent.gid, dirent.uid, oct(dirent.mode&0xFFF)[2:], dirent.ino, dirent.mtime) )    
      
      #create a dictionary for image entries metadata
      entry = dict()
      entry['mode'] = oct(dirent.mode&0xFFF)[2:]
      entry['gid'] = dirent.gid
      entry['uid'] = dirent.uid
      entry['ino'] = dirent.ino
      entry['name'] = name.decode()
      entry['type'] = dirent.mode & qifs.DIRENT_TYPE_MASK # file, device, symlink, dir ...
    
      if entry['type']==qifs.DIRENT_TYPE_SYMLINK: 
        entry['dst'] = dst.rstrip(b'\0').decode() #target of symlink
      elif entry['type']==qifs.DIRENT_TYPE_FILE: 
        entry['offset'] = offset 
        entry['size'] = size  
        name_index[ entry['name'] ] = { 'offset': offset, 'size': size }
      
      entries.append( entry )
      
      ptr += dirent.size
      dirent = qifs.NT_DIRENT_IMAGE_ATTR( *qifs.S_DIRENT_IMAGE_ATTR.unpack_from( self.decomp_image, ptr ) )
         
    image['entries'] = entries
    image['name_index'] = name_index

    return image

  '''
  extract file content from image given its metadata
  '''
  def get_file( self, entry ):
    if entry['type'] == qifs.DIRENT_TYPE_FILE:
      return self.decomp_image[ entry['offset']: entry['offset']+entry['size'] ]

  '''
  extract file content from image given its name, using name_index
  '''
  def get_file_byname( self, name ):
    offset = self.ifs['image']['name_index'][name]['offset']
    size = self.ifs['image']['name_index'][name]['size']
    return self.decomp_image[ offset:offset+size ] 


  def chksum( data ):
    sum = c_long(0)
    for i in range(0, len(data), 4):
      sum.value += ( Struct('>L').unpack_from( data, i )[0] ) 
    return sum.value

  ZIP_COMMENT_SIZE = 16
  '''
  extract all files to a zip archive, with dir tree
  '''
  def files_to_zip( self, zipname ):
    try:
      with zipfile.ZipFile( zipname, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9 ) as zipf:
        for e in self.ifs['image']['entries']:
          if e['type'] == qifs.DIRENT_TYPE_FILE:
            offset = e['offset']
            size = e['size']
            file_data = self.get_file( e )
            zipinfo = zipfile.ZipInfo()
            zipinfo.filename = e['name']
            zipinfo.compress_type = zipfile.ZIP_DEFLATED
            zipinfo.comment = file_data[ :min(qifs.ZIP_COMMENT_SIZE,size) ] #extract first bytes as zip comment
            #print("name=%s mode=%o %x" % (e['name'], int(e['mode'], 8), int(e['mode'], 8)) ) 
            #see https://trac.edgewall.org/attachment/ticket/8919/ZipDownload.patch and https://stackoverflow.com/questions/434641/how-do-i-set-permissions-attributes-on-a-file-in-a-zip-file-using-pythons-zip
            zipinfo.external_attr = int(e['mode'], 8) << 16 #stored in dictionary/json as text in octal
            zipinfo.create_system = 3 #3=unix, 0=MSDOS 
            zipf.writestr( zipinfo, file_data )
    except PermissionError:
      print('Error, can not create %s' % zipname )

  '''
  export metadata as json file
  '''
  def export_metadata( self, jsonfile ):
    with open( jsonfile, 'w' ) as json_file:
      json.dump( self.ifs, json_file, indent=4 )
      
      
          
if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument('imagefile', metavar='imagefile', type=str, action='store', help='image file')
  parser.add_argument('-v', dest='verbose', action='store', type=int, default=0, help='verbose level', required=False)
  parser.add_argument('-u', dest='uncompressed', action='store', help='output uncompressed image in -file-', required=False)
  parser.add_argument('-j', dest='json', action='store', help='output metadata as json file', required=False)
  parser.add_argument('-m', dest='md5', action='store_true', help='compute md5', required=False)
  parser.add_argument('-i', dest='id', action='store_true', help='extract first 16 bytes of files for identification', required=False)
  parser.add_argument('-f', dest='file', action='store', help='extract file', required=False)
  parser.add_argument('-q', dest='quiet', action='store_true', help='no default output', required=False)
  parser.add_argument('-a', dest='archive', action='store', help='extract files in zip archive', required=False)
  args = parser.parse_args()
  #print(args) 

  ifs_image = qifs( args.imagefile, args.quiet, args.verbose )

  if args.uncompressed: #save decompressed image, for example to extract files using a python script and qifs as library
    with open(args.uncompressed, 'wb') as out_uncomp:
      out_uncomp.write(ifs_image.decomp_image)
      if args.verbose:
        print('uncompressed image saved as %s' % args.uncompressed)
    
  #https://github.com/askac/dumpifs/blob/b7bac90e8312eca2796f2003a52791899eb8dcd9/dumpifs.c#L788
  #print( 'image sum %x' % c_ulong( ~chksum( decomp_image ) ).value ) #tentative for image checksum
  if not args.quiet:
    print('Checksums: image=0x%x startup=0x%x' % (ifs_image.ifs['image']['checksum'], ifs_image.ifs['startup_header']['checksum']) )
        
  if args.id: #extract first bytes of each file, store them as metadata and display it
    for e in ifs_image.ifs['image']['entries']:
      if e['type'] == qifs.DIRENT_TYPE_FILE: 
        _size = min( e['size'], qifs.ZIP_COMMENT_SIZE )
        file_data = ifs_image.get_file( e )
        _id = file_data[ :_size ]
        e['hex'] = '%s' % hexlify(_id).decode()
        if not args.quiet:
          print('%s, %s' % (e['name'], _id) )
    
  if args.md5: #compute md5, stores as metadata and display it
    for e in ifs_image.ifs['image']['entries']:
      if e['type'] == qifs.DIRENT_TYPE_FILE: #file
        _md5 = md5( ifs_image.get_file( e ) ).hexdigest()
        e['md5'] = _md5
        if not args.quiet:
          print('%s, %s' % (e['name'], _md5 ) )

  if args.file: #extract one file
    if args.file in ifs_image.ifs['image']['name_index']:
      print('extracting file %s' % args.file )
      basename = os.path.basename( args.file )
      with open(basename, 'wb') as out_bin:
        out_bin.write( ifs_image.get_file_byname( args.file ) )

  if args.json: #export metadata as json file
    ifs_image.export_metadata( args.json )

  if args.archive: #extract files to zip archive
    print('extracting files in %s' % args.archive)
    ifs_image.files_to_zip( args.archive )
            