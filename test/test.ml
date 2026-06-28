let () =
  Alcotest.run "javelin"
    (Test_hid.suite @ Test_report.suite @ Test_event.suite @ Test_history.suite
   @ Test_waybar.suite)
