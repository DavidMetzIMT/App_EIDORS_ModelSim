function error = build_error(msg, code)
    % build an error structure
    error.msg= msg;
    error.code= code; % 0 noerror > 0 error
end