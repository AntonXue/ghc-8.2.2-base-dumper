# coding=utf8

test('ghci001', combined_output, ghci_script, ['ghci001.script'])
test('ghci002', combined_output, ghci_script, ['ghci002.script'])
test('ghci003', combined_output, ghci_script, ['ghci003.script'])
test('ghci004', [ combined_output,
		  when(arch('powerpc64') or arch('powerpc64le'),
                       expect_broken_for(11259,['ghci-ext'])),
                  unless(opsys('mingw32'),extra_ways(['ghci-ext'])) ],
                ghci_script, ['ghci004.script'])
test('ghci005', combined_output, ghci_script, ['ghci005.script'])
test('ghci006', [ combined_output,
                  when(arch('powerpc64') or arch('powerpc64le'),
                       expect_broken_for(11259,['ghci-ext'])),
                  unless(opsys('mingw32'),extra_ways(['ghci-ext'])) ],
                ghci_script, ['ghci006.script'])
test('ghci007', combined_output, ghci_script, ['ghci007.script'])
test('ghci008', combined_output, ghci_script, ['ghci008.script'])
test('ghci009', combined_output, ghci_script, ['ghci009.script'])

# Skip this test: deadlock cannot be detected now, because we wait for
# signals to arrive if there are signal handlers installed, and GHCi
# has a ^C handler installed.
test('ghci010', skip, ghci_script, ['ghci010.script'])

test('ghci011', normal, ghci_script, ['ghci011.script'])
test('ghci012', normal, ghci_script, ['ghci012.script'])
test('ghci013', normal, ghci_script, ['ghci013.script'])
test('ghci014', reqlib('QuickCheck'), ghci_script, ['ghci014.script'])

# Ignore stderr from ghci015, the output is non-deterministic
# (has occasional "thread blocked indefinitely" exceptions), and this
# is part of the test.
# But don't silence both stderr and stdout, as then the test would trivially
# pass when ghci015.hs has errors.
test('ghci015', [reqlib('stm'), ignore_stderr], ghci_script, ['ghci015.script'])

test('ghci016', expect_broken(552), ghci_script, ['ghci016.script'])
test('ghci017', [reqlib('haskell98'), extra_run_opts('-hide-package haskell98')], ghci_script, ['ghci017.script'])
test('ghci018', normal, ghci_script, ['ghci018.script'])
test('ghci019', normal, ghci_script, ['ghci019.script'])
test('ghci020', normal, ghci_script, ['ghci020.script'])
test('ghci021', normal, ghci_script, ['ghci021.script'])
test('ghci022', normal, ghci_script, ['ghci022.script'])

test('ghci023', normal, ghci_script, ['ghci023.script'])
test('ghci024',
     [req_interp, when(fast(), skip)],
     run_command,
     ['$MAKE -s --no-print-directory ghci024'])
test('T9367',
     [req_interp, when(fast() or config.os != 'mingw32', skip)],
     run_command,
     ['$MAKE -s --no-print-directory T9367'])
test('ghci025', extra_files(['Ghci025B.hs', 'Ghci025C.hs', 'Ghci025D.hs']), ghci_script, ['ghci025.script'])
test('ghci026', extra_files(['../prog002']), ghci_script, ['ghci026.script'])

test('ghci027', [], ghci_script, ['ghci027.script'])
test('ghci028', normal, ghci_script, ['ghci028.script'])
test('ghci029', normal, ghci_script, ['ghci029.script'])
test('ghci030', normal, ghci_script, ['ghci030.script'])
test('ghci031', normal, ghci_script, ['ghci031.script'])
test('ghci032', normal, ghci_script, ['ghci032.script'])
test('ghci033', normal, ghci_script, ['ghci033.script'])
test('ghci034', normal, ghci_script, ['ghci034.script'])
test('ghci035', normal, ghci_script, ['ghci035.script'])
test('ghci036', normal, ghci_script, ['ghci036.script'])
test('ghci037', req_interp, run_command, ['$MAKE -s --no-print-directory ghci037'])
test('ghci038', extra_files(['../shell.hs']), ghci_script, ['ghci038.script'])
test('ghci039', normal, ghci_script, ['ghci039.script'])
test('ghci040', normal, ghci_script, ['ghci040.script'])
test('ghci041', normal, ghci_script, ['ghci041.script'])
test('ghci042', normal, ghci_script, ['ghci042.script'])
test('ghci043', normal, ghci_script, ['ghci043.script'])
test('ghci044', normal, ghci_script, ['ghci044.script'])
test('ghci044a', normal, ghci_script, ['ghci044a.script'])
test('ghci045', normal, ghci_script, ['ghci045.script'])
test('ghci046', normal, ghci_script, ['ghci046.script'])
test('ghci047', normal, ghci_script, ['ghci047.script'])
test('ghci048', normal, ghci_script, ['ghci048.script'])
test('ghci049', normal, ghci_script, ['ghci049.script'])
test('ghci050', normal, ghci_script, ['ghci050.script'])
test('ghci051', normal, ghci_script, ['ghci051.script'])
test('ghci052', normal, ghci_script, ['ghci052.script'])
test('ghci053', normal, ghci_script, ['ghci053.script'])
test('ghci054', normal, ghci_script, ['ghci054.script'])
test('ghci055', combined_output, ghci_script, ['ghci055.script'])

test('ghci056',
     [pre_cmd('$MAKE -s --no-print-directory ghci056_setup'),
      extra_run_opts('ghci056_c.o')],
     ghci_script, ['ghci056.script'])

test('ghci057', normal, ghci_script, ['ghci057.script'])
test('ghci060', normal, ghci_script, ['ghci060.script'])
test('ghci061', normal, ghci_script, ['ghci061.script'])
test('ghci062', [extra_files(['ghci062/', 'ghci062/Test.hs']),
                 when(config.have_ext_interp, extra_ways(['ghci-ext']))],
		ghci_script, ['ghci062.script'])
test('ghci063', normal, ghci_script, ['ghci063.script'])

test('T2452', normal, ghci_script, ['T2452.script'])
test('T2766', normal, ghci_script, ['T2766.script'])

test('T1914', [], ghci_script, ['T1914.script'])

test('T2182ghci', normal, ghci_script, ['T2182ghci.script'])
test('T2182ghci2', [extra_hc_opts("-XNoImplicitPrelude")], ghci_script, ['T2182ghci2.script'])
test('T2976', normal, ghci_script, ['T2976.script'])
test('T2816', normal, ghci_script, ['T2816.script'])
test('T789', normal, ghci_script, ['T789.script'])
test('T3263', normal, ghci_script, ['T3263.script'])
test('T4051', normal, ghci_script, ['T4051.script'])
test('T4087', normal, ghci_script, ['T4087.script'])
test('T4015', normal, ghci_script, ['T4015.script'])
test('T4127', normal, ghci_script, ['T4127.script'])
test('T4127a', normal, ghci_script, ['T4127a.script'])
test('T4316', reqlib('mtl'), ghci_script, ['T4316.script'])
test('T4832', normal, ghci_script, ['T4832.script'])
test('T5045', normal, ghci_script, ['T5045.script'])
test('T5130', normal, ghci_script, ['T5130.script'])
test('T5417', normal, ghci_script, ['T5417.script'])
test('T5545', normal, ghci_script, ['T5545.script'])
test('T5557', combined_output, ghci_script, ['T5557.script'])
test('T5566', normal, ghci_script, ['T5566.script'])
test('GhciKinds', normal, ghci_script, ['GhciKinds.script'])
test('T5564', normal, ghci_script, ['T5564.script'])
test('Defer02', extra_files(['../../typecheck/should_run/Defer01.hs']), ghci_script, ['Defer02.script'])
test('T5820', normal, ghci_script, ['T5820.script'])
test('T5836', normal, ghci_script, ['T5836.script'])
test('T5979',
    [reqlib('transformers'),
     normalise_slashes,
     normalise_version("transformers")],
    ghci_script, ['T5979.script'])
test('T5975a', [pre_cmd('touch föøbàr1.hs')], ghci_script, ['T5975a.script'])
test('T5975b', [pre_cmd('touch föøbàr2.hs'), extra_hc_opts('föøbàr2.hs')],
     ghci_script, ['T5975b.script'])
test('T6027ghci', normal, ghci_script, ['T6027ghci.script'])

test('T6007', normal, ghci_script, ['T6007.script'])
test('T6091', normal, ghci_script, ['T6091.script'])
test('T6106', [extra_files(['../shell.hs']),
               pre_cmd('$MAKE -s --no-print-directory T6106_prep')],
     ghci_script, ['T6106.script'])
test('T6105', normal, ghci_script, ['T6105.script'])
test('T7117', normal, ghci_script, ['T7117.script'])
test('ghci058', [extra_files(['../shell.hs']),
                 cmd_prefix('ghciWayFlags=' + config.ghci_way_flags)],
     ghci_script, ['ghci058.script'])
test('T7587', normal, ghci_script, ['T7587.script'])
test('T7688', normal, ghci_script, ['T7688.script'])
test('T7627', normal, ghci_script, ['T7627.script'])
test('T7627b', normal, ghci_script, ['T7627b.script'])
test('T7586', normal, ghci_script, ['T7586.script'])
test('T4175', normal, ghci_script, ['T4175.script'])
test('T6018ghci', normal, ghci_script, ['T6018ghci.script'])
test('T6018ghcifail', normal, ghci_script, ['T6018ghcifail.script'])
test('T6018ghcirnfail', normal, ghci_script, ['T6018ghcirnfail.script'])
test('T7730', combined_output, ghci_script, ['T7730.script'])
test('T7872', normal, ghci_script, ['T7872.script'])
test('T7873', normal, ghci_script, ['T7873.script'])
test('T7939', normal, ghci_script, ['T7939.script'])
test('T7894', normal, ghci_script, ['T7894.script'])
test('T8116', normal, ghci_script, ['T8116.script'])
test('T8113', normal, ghci_script, ['T8113.script'])
test('T8172', when(opsys('mingw32'), normalise_drive_letter),
     ghci_script, ['T8172.script'])
test('T8215', normal, ghci_script, ['T8215.script'])
test('T8353', extra_files(['Defer03.hs']), ghci_script, ['T8353.script'])
test('T8357', normal, ghci_script, ['T8357.script'])
test('T8383', normal, ghci_script, ['T8383.script'])
test('T8469', normal, ghci_script, ['T8469.script'])
test('T8485', normal, ghci_script, ['T8485.script'])
test('T8535', normal, ghci_script, ['T8535.script'])
test('T8639', normal, ghci_script, ['T8639.script'])
test('T8640', normal, ghci_script, ['T8640.script'])
test('T8579', normal, ghci_script, ['T8579.script'])
test('T8649', normal, ghci_script, ['T8649.script'])
test('T8674', normal, ghci_script, ['T8674.script'])
test('T8696', normal, ghci_script, ['T8696.script'])
test('T8776', normal, ghci_script, ['T8776.script'])
test('ghci059', normal, ghci_script, ['ghci059.script'])
test('T8831', normal, ghci_script, ['T8831.script'])
test('T8917', normal, ghci_script, ['T8917.script'])
test('T8931', normal, ghci_script, ['T8931.script'])
test('T8959', normal, ghci_script, ['T8959.script'])
test('T8959b', normal, ghci_script, ['T8959b.script'])
test('T9181', normal, ghci_script, ['T9181.script'])
test('T9086b', normal, ghci_script, ['T9086b.script'])
test('T9140', combined_output, ghci_script, ['T9140.script'])
test('T9658', normal, ghci_script, ['T9658.script'])
test('T9293', extra_files(['ghci057.hs']), ghci_script, ['T9293.script'])
test('T9762',
 [ unless(have_dynamic(),skip)
 , pre_cmd('$MAKE -s --no-print-directory T9762_prep')
 ],
 ghci_script, ['T9762.script'])
test('T9881', normal, ghci_script, ['T9881.script'])
test('T9878', [], ghci_script, ['T9878.script'])
test('T9878b', [extra_run_opts('-fobject-code')], ghci_script,
     ['T9878b.script'])
test('T10018', normal, ghci_script, ['T10018.script'])
test('T10122', normal, ghci_script, ['T10122.script'])

test('T10321', normal, ghci_script, ['T10321.script'])

test('T10408', req_interp, run_command,
    ['$MAKE -s --no-print-directory T10408'])
test('T10248', normal, ghci_script, ['T10248.script'])
test('T10110', normal, ghci_script, ['T10110.script'])
test('T10322', normal, ghci_script, ['T10322.script'])
test('T10439', normal, ghci_script, ['T10439.script'])
test('T10466', normal, ghci_script, ['T10466.script'])
test('T10501', normal, ghci_script, ['T10501.script'])
test('T10508', normal, ghci_script, ['T10508.script'])
test('T10520', normal, ghci_script, ['T10520.script'])
test('T10663', normal, ghci_script, ['T10663.script'])
test('T10989', [], ghci_script, ['T10989.script'])
test('T11098', normal, ghci_script, ['T11098.script'])
test('T8316', expect_broken(8316), ghci_script, ['T8316.script'])
test('T11252', normal, ghci_script, ['T11252.script'])

test('T10576a', [extra_files(['T10576.hs']), expect_broken(10576)],
     ghci_script, ['T10576a.script'])
test('T10576b', [extra_files(['T10576.hs']), expect_broken(10576)],
     ghci_script, ['T10576b.script'])
test('T11051a', normal, ghci_script, ['T11051a.script'])
test('T11051b', normal, ghci_script, ['T11051b.script'])
test('T11266', ignore_stdout, ghci_script, ['T11266.script'])

test('T11389', req_interp, run_command, ['$MAKE -s --no-print-directory T11389'])
test('T11524a', normal, ghci_script, ['T11524a.script'])
test('T11456', normal, ghci_script, ['T11456.script'])
test('TypeAppData', normal, ghci_script, ['TypeAppData.script'])
test('T11728', normal, ghci_script, ['T11728.script'])
test('T11376', normal, ghci_script, ['T11376.script'])
test('T12007', normal, ghci_script, ['T12007.script'])
test('T11975', normal, ghci_script, ['T11975.script'])
test('T10963', normal, ghci_script, ['T10963.script'])
test('T11547', normal, ghci_script, ['T11547.script'])
test('T12520', normal, ghci_script, ['T12520.script'])
test('T12091',
     [expect_broken(12091), extra_run_opts('-fobject-code')],
     ghci_script, ['T12091.script'])
test('T12523', normal, ghci_script, ['T12523.script'])
test('T12024', normal, ghci_script, ['T12024.script'])
test('T12447', expect_broken(12447), ghci_script, ['T12447.script'])
test('T10249', normal, ghci_script, ['T10249.script'])
test('T12550', normal, ghci_script, ['T12550.script'])
test('StaticPtr', normal, ghci_script, ['StaticPtr.script'])
test('T13202', normal, ghci_script, ['T13202.script'])
test('T13202a', normal, ghci_script, ['T13202a.script'])
test('T13385', [extra_hc_opts("-XRebindableSyntax")], ghci_script, ['T13385.script'])
test('T13466', normal, ghci_script, ['T13466.script'])
test('GhciCurDir', normal, ghci_script, ['GhciCurDir.script'])
