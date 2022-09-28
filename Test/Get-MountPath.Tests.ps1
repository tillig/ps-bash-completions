BeforeAll {
  . $PSScriptRoot/../PSBashCompletions/Get-MountPath.ps1
}

Describe "Get-MountPath" {
  It "gets the mount path from Windows Git Bash" {
    $mount = @(
      'C:/Program Files/Git on / type ntfs (binary,noacl,auto)',
      'C:/Program Files/Git/usr/bin on /bin type ntfs (binary,noacl,auto)',
      'C:/Users/tillig/AppData/Local/Temp on /tmp type ntfs (binary,noacl,posix=0,usertemp)',
      'C: on /c type ntfs (binary,noacl,posix=0,user,noumount,auto)'
    )
    Get-MountPath $mount | Should -Be "/"
  }
  It "gets the mount path from WSL2 Ubuntu" {
    $mount = @(
      'none on /mnt/wsl type tmpfs (rw,relatime)',
      'drivers on /usr/lib/wsl/drivers type 9p (ro,nosuid,nodev,noatime,dirsync,aname=drivers;fmask=222;dmask=222,mmap,access=client,msize=65536,trans=fd,rfd=7,wfd=7)',
      'none on /usr/lib/wsl/lib type overlay (rw,relatime,lowerdir=/gpu_lib_packaged:/gpu_lib_inbox,upperdir=/gpu_lib/rw/upper,workdir=/gpu_lib/rw/work)',
      '/dev/sdc on / type ext4 (rw,relatime,discard,errors=remount-ro,data=ordered)',
      'none on /mnt/wslg type tmpfs (rw,relatime)',
      '/dev/sdc on /mnt/wslg/distro type ext4 (ro,relatime,discard,errors=remount-ro,data=ordered)',
      'rootfs on /init type rootfs (rw,size=4043596k,nr_inodes=1010899)',
      'none on /dev type devtmpfs (rw,nosuid,relatime,size=4043624k,nr_inodes=1010906,mode=755)',
      'sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,noatime)',
      'proc on /proc type proc (rw,nosuid,nodev,noexec,noatime)',
      'devpts on /dev/pts type devpts (rw,nosuid,noexec,noatime,gid=5,mode=620,ptmxmode=000)',
      'none on /run type tmpfs (rw,nosuid,nodev,mode=755)',
      'none on /run/lock type tmpfs (rw,nosuid,nodev,noexec,noatime)',
      'none on /run/shm type tmpfs (rw,nosuid,nodev,noatime)',
      'none on /run/user type tmpfs (rw,nosuid,nodev,noexec,noatime,mode=755)',
      'binfmt_misc on /proc/sys/fs/binfmt_misc type binfmt_misc (rw,relatime)',
      'tmpfs on /sys/fs/cgroup type tmpfs (rw,nosuid,nodev,noexec,relatime,mode=755)',
      'cgroup2 on /sys/fs/cgroup/unified type cgroup2 (rw,nosuid,nodev,noexec,relatime,nsdelegate)',
      'cgroup on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,cpuset)',
      'cgroup on /sys/fs/cgroup/cpu type cgroup (rw,nosuid,nodev,noexec,relatime,cpu)',
      'cgroup on /sys/fs/cgroup/cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,cpuacct)',
      'cgroup on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,blkio)',
      'cgroup on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,memory)',
      'cgroup on /sys/fs/cgroup/devices type cgroup (rw,nosuid,nodev,noexec,relatime,devices)',
      'cgroup on /sys/fs/cgroup/freezer type cgroup (rw,nosuid,nodev,noexec,relatime,freezer)',
      'cgroup on /sys/fs/cgroup/net_cls type cgroup (rw,nosuid,nodev,noexec,relatime,net_cls)',
      'cgroup on /sys/fs/cgroup/perf_event type cgroup (rw,nosuid,nodev,noexec,relatime,perf_event)',
      'cgroup on /sys/fs/cgroup/net_prio type cgroup (rw,nosuid,nodev,noexec,relatime,net_prio)',
      'cgroup on /sys/fs/cgroup/hugetlb type cgroup (rw,nosuid,nodev,noexec,relatime,hugetlb)',
      'cgroup on /sys/fs/cgroup/pids type cgroup (rw,nosuid,nodev,noexec,relatime,pids)',
      'cgroup on /sys/fs/cgroup/rdma type cgroup (rw,nosuid,nodev,noexec,relatime,rdma)',
      'cgroup on /sys/fs/cgroup/misc type cgroup (rw,nosuid,nodev,noexec,relatime,misc)',
      'none on /mnt/wslg/versions.txt type overlay (rw,relatime,lowerdir=/systemvhd,upperdir=/system/rw/upper,workdir=/system/rw/work)',
      'none on /mnt/wslg/doc type overlay (rw,relatime,lowerdir=/systemvhd,upperdir=/system/rw/upper,workdir=/system/rw/work)',
      'none on /tmp/.X11-unix type tmpfs (rw,relatime)',
      'drvfs on /mnt/c type 9p (rw,noatime,dirsync,aname=drvfs;path=C:\;uid=1000;gid=1000;symlinkroot=/mnt/,mmap,access=client,msize=262144,trans=virtio)'
    )
    Get-MountPath $mount | Should -Be "/mnt/"
  }
  It "gets the mount path from Mac bash" {
    $mount = @(
      '/dev/disk1s1s1 on / (apfs, sealed, local, read-only, journaled)',
      'devfs on /dev (devfs, local, nobrowse)',
      '/dev/disk1s5 on /System/Volumes/VM (apfs, local, noexec, journaled, noatime, nobrowse)',
      '/dev/disk1s3 on /System/Volumes/Preboot (apfs, local, journaled, nobrowse)',
      '/dev/disk1s6 on /System/Volumes/Update (apfs, local, journaled, nobrowse)',
      '/dev/disk1s2 on /System/Volumes/Data (apfs, local, journaled, nobrowse)',
      'map auto_home on /System/Volumes/Data/home (autofs, automounted, nobrowse)',
      'map -fstab on /System/Volumes/Data/Network/Servers (autofs, automounted, nobrowse)',
      '//GUEST:@Windows%2011%20Pro%20-%20Dev._smb._tcp.local/%5BC%5D%20Windows%2011%20Pro%20-%20Dev on /Volumes/[C] Windows 11 Pro - Dev.hidden (smbfs, nodev, noexec, nosuid, noowners, noatime, nobrowse, mounted by tillig)'
    )
    Get-MountPath $mount | Should -Be "/"
  }
}
