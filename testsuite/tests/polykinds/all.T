test('PolyKinds09', normal, compile_and_run, [''])
test('PolyKinds10', normal, compile_and_run, [''])

test('PolyKinds01', normal, compile, [''])
test('PolyKinds03', normal, compile, [''])
test('PolyKinds05', normal, compile, [''])
test('PolyKinds08', normal, compile, [''])
test('PolyKinds11', normal, compile, [''])
test('PolyKinds13', normal, compile, [''])

test('PolyKinds02', normal, compile_fail, [''])
test('PolyKinds04', normal, compile_fail, [''])
test('PolyKinds06', normal, compile_fail, [''])
test('PolyKinds07', normal, compile_fail, [''])

test('PolyKinds12', normal, compile, [''])

test('Freeman', normal, compile_and_run, [''])
test('MonoidsTF', normal, compile_and_run, [''])
test('MonoidsFD', normal, compile_and_run, [''])

test('T5798', normal, compile, [''])
test('T5770', normal, compile, [''])
test('T5771', normal, compile, [''])
test('T5717', normal, compile, [''])
test('T5862', normal, compile, [''])
test('T5912', normal, compile, [''])
test('T5881', normal, run_command, ['$MAKE -s --no-print-directory T5881'])
test('T5716', normal, compile_fail, [''])
test('T5716a', normal, compile_fail, [''])
test('T5937', normal, compile, [''])
test('T5935', normal, compile, [''])
test('T5938', normal, compile, [''])
test('T5948', normal, compile, [''])
test('T6020', normal, compile, [''])
test('T6035', normal, compile, [''])
test('T6036', normal, compile, [''])
test('T6025', normal, run_command, ['$MAKE -s --no-print-directory T6025'])
test('T6002', normal, compile, [''])
test('T6039', normal, compile_fail, [''])
test('T6021', normal, compile_fail, [''])
test('T6020a', normal, compile, [''])
test('T6044', normal, compile, [''])
test('T6054', normal, run_command, ['$MAKE -s --no-print-directory T6054'])
test('T6081', normal, compile, [''])
test('T6015', normal, compile, [''])
test('T6015a', normal, compile, [''])
test('T6068', normal, ghci_script, ['T6068.script'])
test('RedBlack', normal, compile, [''])
test('T6118', normal, compile,[''])
test('T6137', normal, compile,[''])
test('T6093', normal, compile,[''])
test('T6049', normal, compile,[''])
test('T6129', normal, compile_fail,[''])
test('T7053', normal, compile,[''])
test('T7053a', normal, compile,[''])
test('T7020', normal, compile,[''])
test('T7022', normal, run_command, ['$MAKE -s --no-print-directory T7022'])
test('T7073', normal, compile,[''])
test('T7128', normal, compile,[''])
test('T7151', normal, compile_fail,[''])
test('T7095', normal, compile,[''])
test('T7090', normal, compile,[''])
test('T7272', [], multimod_compile, ['T7272.hs', '-v0'])
test('T7176', normal, compile,[''])
test('T7224', normal, compile_fail,[''])
test('T7230', normal, compile_fail,[''])
test('T7238', normal, compile,[''])
test('T7278', normal, compile_fail,[''])
test('T7328', normal, compile_fail,[''])
test('T7332', normal, compile,[''])
test('T7347', normal, compile,[''])
test('T7341', normal, compile_fail,[''])
test('T7422', normal, compile,[''])
test('T7433', normal, compile_fail,[''])
test('T7438', normal, run_command, ['$MAKE -s --no-print-directory T7438'])
test('T7404', normal, compile_fail,[''])
test('T7502', normal, compile,[''])
test('T7488', normal, compile,[''])
test('T7594', normal, compile_fail,[''])
test('T7524', normal, compile_fail,[''])
test('T7601', normal, compile,[''])
test('T7805', normal, compile_fail,[''])
test('T7916', normal, compile,[''])
test('T7973', normal, compile,['-O'])
test('T7939a', normal, compile_fail, [''])
test('T8132', normal, compile_fail, [''])
test('T8359', normal, compile, [''])
test('T8391', normal, compile, [''])
test('T8449', normal, run_command, ['$MAKE -s --no-print-directory T8449'])
test('T8534', normal, compile, [''])
test('T8566', normal, compile_fail,[''])
test('T8616', normal, compile_fail,[''])
test('T8566a', normal, compile,[''])
test('T7481', normal, compile,[''])
test('T8705', normal, compile, [''])
test('T8985', normal, compile, [''])
test('T9106', normal, compile_fail, [''])
test('T9144', normal, compile_fail, [''])
test('T9222', normal, compile_fail, [''])
test('T9264', normal, compile, [''])
test('T9263', normal, run_command, ['$MAKE -s --no-print-directory T9263'])
test('T9063', normal, compile, [''])
test('T9200', normal, compile, [''])
test('T9200b', normal, compile_fail, [''])
test('T9750', normal, compile, [''])
test('T9569', normal, compile, [''])
test('T9838', normal, multimod_compile, ['T9838.hs','-v0'])
test('T9574', normal, compile_fail, [''])
test('T9833', normal, compile, [''])
test('T7908', normal, compile, [''])
test('PolyInstances', normal, compile, [''])
test('T10041', normal, compile, [''])
test('T10451', normal, compile_fail, [''])
test('T10516', normal, compile_fail, [''])
test('T10503', normal, compile_fail, [''])
test('T10570', normal, compile_fail, [''])
test('T10670', normal, compile, [''])
test('T10670a', normal, compile, [''])
test('T10134', normal, multimod_compile, ['T10134.hs','-v0'])
test('T10742', normal, compile, [''])
test('T10934', normal, compile, [''])
test('T11142', normal, compile_fail, [''])
test('SigTvKinds', normal, compile, [''])
test('SigTvKinds2', expect_broken(11203), compile_fail, [''])
test('T9017', normal, compile_fail, [''])
test('TidyClassKinds', normal, compile_fail, ['-fprint-explicit-kinds'])
test('T11249', normal, compile, [''])
test('T11248', normal, compile, [''])
test('T11278', normal, compile, [''])
test('T11255', normal, compile, [''])
test('T11459', normal, compile_fail, [''])
test('T11466', normal, compile_fail, [''])
test('T11480a', normal, compile, [''])
test('T11480b', normal, compile, [''])
test('T11523', normal, compile, [''])
test('T11520', normal, compile_fail, [''])
test('T11516', normal, compile_fail, [''])
test('T11362', normal, compile, ['-dunique-increment=-1'])
  # -dunique-increment=-1 doesn't work inside the file
test('T11399', normal, compile_fail, [''])
test('T11611', normal, compile_fail, [''])
test('T11616', normal, compile, [''])
test('T11648', normal, compile, [''])
test('T11648b', normal, compile_fail, [''])
test('KindVType', normal, compile_fail, [''])
test('T11821', normal, compile, [''])
test('T11821a', normal, compile, [''])
test('T11640', normal, compile, [''])
test('T11554', normal, compile_fail, [''])
test('T12055', normal, compile, [''])
test('T12055a', normal, compile_fail, [''])
test('T12593', normal, compile_fail, [''])
test('T12668', normal, compile, [''])
test('T12718', normal, compile, [''])
test('T12444', normal, compile_fail, [''])
test('T12885', normal, compile, [''])
test('T13267', normal, compile_fail, [''])
test('T13394a', normal, compile, [''])
test('T13394', normal, compile, [''])
test('T13371', normal, compile, [''])
test('T13393', normal, compile_fail, [''])
test('T13555', normal, compile_fail, [''])
test('T13625', normal, compile_fail, [''])
