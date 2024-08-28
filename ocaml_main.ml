let () =
  match Val_exp.validate_extract "test_valid.xml" with
    None -> ANSITerminal.(printf [red; Bold] "Invalid document\n")
    | Some s  ->
      ANSITerminal.(printf [green; Bold] "Valid document, orderperson: %s\n" s)