function error = build_error(msg, code)
    %BUILD_ERROR build an error structure
    error.msg= msg;
    error.code= code; % 0 noerror > 0 error
end