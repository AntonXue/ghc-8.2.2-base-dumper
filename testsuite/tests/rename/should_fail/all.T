
test('rnfail001', normal, compile_fail, [''])
test('rnfail002', normal, compile_fail, [''])
test('rnfail003', normal, compile_fail, [''])
test('rnfail004', normal, compile_fail, [''])
test('rnfail007', normal, compile_fail, [''])
test('rnfail008', normal, compile_fail, [''])
test('rnfail009', normal, compile_fail, [''])
test('rnfail010', normal, compile_fail, [''])
test('rnfail011', normal, compile_fail, [''])
test('rnfail012', normal, compile_fail, [''])
test('rnfail013', normal, compile_fail, [''])

test('rnfail015', normal, compile_fail, [''])
test('rnfail016', normal, compile_fail, [''])
test('rnfail016a', normal, compile_fail, [''])
test('rnfail017', normal, compile_fail, [''])
test('rnfail018', normal, compile_fail, [''])
test('rnfail019', normal, compile_fail, [''])
test('rnfail020', normal, compile, [''])	# Succeeds now (Jan07)
test('rnfail021', normal, compile_fail, [''])
test('rnfail022', normal, compile_fail, [''])
test('rnfail023', normal, compile_fail, [''])
test('rnfail024', normal, compile_fail, [''])
test('rnfail025', normal, compile_fail, [''])
test('rnfail026', normal, compile_fail, [''])
test('rnfail027', normal, compile_fail, [''])
test('rnfail028', normal, compile_fail, [''])
test('rnfail029', normal, compile_fail, [''])
test('rnfail030', normal, compile_fail, [''])
test('rnfail031', normal, compile_fail, [''])
test('rnfail032', normal, compile_fail, [''])
test('rnfail033', normal, compile_fail, [''])
test('rnfail034', normal, compile_fail, [''])
test('rnfail035', normal, compile_fail, [''])

# Missing:
# test('rnfail037', normal, compile_fail, [''])

test('rnfail039', normal, compile_fail, [''])

test('rnfail040', [extra_files(['Rnfail040_A.hs'])], multimod_compile_fail, ['rnfail040', '-v0'])
test('rnfail041', normal, compile_fail, [''])
test('rnfail042', normal, compile_fail, [''])

test('rnfail043', unless(doing_ghci, skip), compile_fail, ['-v0'])
test('rnfail044', normal, compile_fail, [''])
test('rnfail045', normal, compile_fail, [''])
test('rnfail046', normal, compile_fail, [''])
test('rnfail047', [extra_files(['RnFail047_A.hs', 'RnFail047_A.hs-boot'])], multimod_compile_fail, ['rnfail047', '-v0'])
test('rnfail048', normal, compile_fail, [''])
test('rnfail049', normal, compile_fail, [''])
test('rnfail050', normal, compile_fail, [''])
test('rnfail051', normal, compile_fail, [''])
test('rnfail052', normal, compile_fail, [''])
test('rnfail053', normal, compile_fail, [''])
test('rnfail054', normal, compile_fail, [''])
test('rnfail055', [extra_files(['RnFail055.hs', 'RnFail055.hs-boot', 'RnFail055_aux.hs'])], multimod_compile_fail, ['RnFail055', '-v0'])
test('rnfail056', normal, compile_fail, [''])
test('rnfail057', normal, compile_fail, [''])

test('rn_dup', normal, compile_fail, [''])
test('T2310', normal, compile_fail, [''])
test('T2490', normal, compile_fail, [''])
test('T2901', normal, compile_fail, [''])
test('T2723', normal, compile, [''])  # Warnings only
test('T2993', normal, compile_fail, [''])
test('T3265', normal, compile_fail, [''])
test('T3792', normal, compile_fail, [''])
test('T4042', normal, compile_fail, [''])

test('mc13', normal, compile_fail, [''])
test('mc14', normal, compile_fail, [''])
test('T5211', normal, compile, [''])  # Warnings only
test('T1595a', normal, compile_fail, [''])
test('T5281', normal, multimod_compile, ['T5281', '-v0'])  # Warnings only
test('T5372', [], multimod_compile_fail, ['T5372', '-v0'])
test('T5385', [], multimod_compile_fail, ['T5385', '-v0'])
test('T5513', normal, compile_fail, [''])
test('T5533', normal, compile_fail, [''])
test('T5589', normal, compile_fail, [''])
test('Misplaced', normal, compile_fail, [''])
test('T5657', normal, compile_fail, [''])
test('T5745', [], multimod_compile_fail, ['T5745', '-v0'])
test('T5892a', normal, compile_fail, ['-package containers'])
test('T5892b', normal, compile_fail, ['-package containers'])
test('T5951', normal, compile_fail, [''])
test('T6018rnfail', normal, compile_fail, [''])
test('T6060', normal, compile_fail, [''])
test('T6148', normal, compile_fail, [''])
test('T7164', normal, compile_fail, [''])
test('T7338', normal, compile_fail, [''])
test('T7338a', normal, compile_fail, [''])
test('T7454', normal, compile, [''])
test('T7906', normal, compile_fail, [''])
test('T7937', normal, compile_fail, [''])
test('T7943', normal, compile_fail, [''])
test('T8448', normal, compile_fail, [''])
test('T8149', normal, compile, [''])
test('RnStaticPointersFail01', [], compile_fail, [''])
test('RnStaticPointersFail02', [], compile_fail, [''])
test('RnStaticPointersFail03', [], compile_fail, ['-dsuppress-uniques'])
test('T9006', [], multimod_compile_fail, ['T9006', '-v0'])
test('T9156', normal, compile_fail, [''])
test('T9177', normal, compile_fail, [''])
test('T9177a', normal, compile_fail, [''])
test('T9436', normal, compile_fail, [''])
test('T9437', normal, compile_fail, [''])
test('T9077', normal, compile_fail, [''])
test('T9815', normal, compile_fail, [''])

test('T9032',
     normal,
     run_command,
     ['$MAKE -s --no-print-directory T9032'])
test('T10618', normal, compile_fail, [''])
test('T10668', normal, compile_fail, [''])
test('T5001b', normal, compile_fail, [''])
test('T10781', normal, compile_fail, [''])
test('T11071', normal, compile_fail, [''])
test('T11071a', normal, compile_fail, [''])
test('T11663', normal, compile_fail, [''])
test('T12229', normal, compile, [''])
test('T12681', normal, multimod_compile_fail, ['T12681','-v0'])
test('T12686', normal, compile_fail, [''])
test('T11592', normal, compile_fail, [''])
test('T12879', normal, compile_fail, [''])
test('T13568', normal, multimod_compile_fail, ['T13568','-v0'])
test('T13947', normal, compile_fail, [''])
