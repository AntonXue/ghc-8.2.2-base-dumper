def just_the_deriving( msg ):
  return msg[0:msg.find('Filling in method body')]

test('drv001', normal, compile, [''])
test('drv002', normal, compile, [''])
test('drv003', normal, compile, [''])
test('drv004', normal, compile, [''])
test('drv005', normal, compile, [''])
test('drv006', normal, compile, [''])
test('drv007', normal, compile, [''])
test('drv008', normal, compile, [''])
test('drv009', normal, compile, [''])
test('drv010', normal, compile, [''])
test('drv011', normal, compile, [''])
test('drv012', normal, compile, [''])
test('drv013', normal, compile, [''])
test('drv014', normal, compile, [''])
test('drv015', normal, compile, [''])
test('drv020', normal, compile, [''])
test('drv022', normal, compile, [''])
test('deriving-1935', normal, compile, [''])
test('T1830_2', normal, compile, [''])
test('T2378', normal, compile, [''])
test('T2721', normal, compile, [''])
test('T2856', normal, compile, [''])
test('T3057', [], multimod_compile, ['T3057', '-v0'])
test('T3012', normal, compile, [''])
test('T3965', normal, compile, [''])
test('T4220', normal, compile, [''])
test('T4302', normal, compile, [''])
test('T4325', normal, compile, [''])
test('T4816', normal, compile, [''])
test('T4966', normal, compile, [''])
test('T5939', normal, compile, [''])

test('drv-functor1', normal, compile, [''])
test('drv-functor2', normal, compile, [''])
test('drv-foldable-traversable1', normal, compile, [''])
test('T6031', [], multimod_compile, ['T6031', '-v0 -O'])
# Adding -O on T6031 to expose Trac #11245 regardless of way
test('T1133', [], run_command, ['$MAKE --no-print-directory -s T1133'])
test('T7704', normal, compile, [''])
test('T7710', normal, compile, [''])

test('AutoDeriveTypeable', normal, compile, [''])

test('T8138', reqlib('primitive'), compile, ['-O2'])
test('T8165', normal, compile, [''])
test('T8631', normal, compile, [''])
test('T8758', [], multimod_compile, ['T8758a', '-v0'])
test('T8678', normal, compile, [''])
test('T8865', normal, compile, [''])
test('T8893', normal, compile, [''])
test('T8950', normal, compile, [''])
test('T8963', normal, compile, [''])
test('T7269', normal, compile, [''])
test('T9069', normal, compile, [''])
test('T9359', normal, compile, [''])
test('T4896', normal, compile, [''])
test('T7947', [], multimod_compile, ['T7947', '-v0'])
test('T10561', normal, compile, [''])
test('T10487', [], multimod_compile, ['T10487', '-v0'])
test('T10524', normal, compile, [''])
test('T11148', normal, run_command,
     ['$MAKE -s --no-print-directory T11148'])
test('T9968', normal, compile, [''])
test('T9968a', normal, compile, [''])
test('T11174', normal, compile, [''])
test('T11416', normal, compile, [''])
test('T11396', normal, compile, [''])
test('T11357', normal, compile, [''])
test('T11509_2', normal, compile, [''])
test('T11509_3', normal, compile, [''])
test('T11732a', normal, compile, [''])
test('T11732b', normal, compile, [''])
test('T11732c', normal, compile, [''])
test('T11833', normal, compile, [''])
test('T12144_1', normal, compile, [''])
test('T12144_2', normal, compile, [''])
test('T12245', normal, compile, [''])
test('T12399', normal, compile, [''])
test('T12423', normal, compile, [''])
test('T12583', normal, compile, [''])
test('T12594', normal, compile, [''])
test('T12616', normal, compile, [''])
test('T12688', normal, compile, [''])
test('T12814', normal, compile, ['-Wredundant-constraints'])
test('T13272', normal, compile, [''])
test('T13272a', normal, compile, [''])
test('T13297', normal, compile, [''])
test('T14331', normal, compile, [''])
test('T14339', normal, compile, [''])
