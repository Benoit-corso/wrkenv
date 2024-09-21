" ref: https://sauravomar01.medium.com/configure-custom-header-template-in-vim-editor-6d578e440da3
let s:asciiart = [
			\"............................... ",
			\":=...........................=: ",
			\":=:                         :=: ",
			\":=:                         :=: ",
			\":=:     laplateforme.io     :=: ",
			\":='.........................'=: ",
			\"'++++#=-*+*+*+*#*+*+*+*-=#++++' ",
			\"     #=-               -=#      ",
			\"┌.   #=-  ..       ..  -=#   .┐ ",
			\"│×-. #=-.+*-..   ..-*+.-=# .-×│ ",
			\" '+:-+=-:'¯¯*:-■-:*¯¯':-=+-:+'  ",
			\"   ':..:'    ':.:'    ':..:'    ",
			\]

let s:start		= '/*'
let s:end		= '*/'
let s:fill		= '*'
let s:length	= 80
let s:margin	= 5

let s:types		= {
				\'\.c$\|\.h$\|\.cc$\|\.hh$\|\.cpp$\|\.hpp$\|\.php':
				\['/*', '*/', '*', 80],
				\'\.htm$\|\.html$\|\.xml$':
				\['<!--', '-->', '*', 120],
				\'\.js$':
				\['//', '//', '*', 120],
				\'\.tex$':
				\['%', '%', '*', 80],
				\'\.ml$\|\.mli$\|\.mll$\|\.mly$':
				\['(*', '*)', '*', 80],
				\'\.vim$\|\vimrc$':
				\['"', '"', '*', 120],
				\'\.el$\|\emacs$':
				\[';', ';', '*', 120],
				\'\.f90$\|\.f95$\|\.f03$\|\.f$\|\.for$':
				\['!', '!', '/', 80],
				\'\.sh$':
				\['#', '#', '*', 80]
				\}

function! s:filetype()
	let l:f = s:filename()

	for type in keys(s:types)
		if l:f =~ type
			let s:start		= s:types[type][0]
			let s:end		= s:types[type][1]
			let s:fill		= s:types[type][2]
			let s:length	= s:types[type][3]
		endif
	endfor
endfunction

function! s:ascii(n)
	return s:asciiart[a:n - 3]
endfunction

function! s:textline(left, right)
	let l:left = strpart(a:left, 0, s:length - s:margin * 2 - strlen(a:right))
	return s:start . repeat(' ', s:margin - strlen(s:start)) . l:left . repeat(' ', s:length - s:margin * 2 - strlen(l:left) - strlen(a:right)) . a:right . repeat(' ', s:margin - strlen(s:end)) . s:end
endfunction

function! s:line(n)
	if a:n == 1 || a:n == 11 " top and bottom line
		return s:start . ' ' . repeat(s:fill, s:length - strlen(s:start) - strlen(s:end) - 2) . ' ' . s:end
	elseif a:n == 2 || a:n == 10 " blank line
		return s:textline('', '')
	elseif a:n == 3 || a:n == 5 || a:n == 7 " empty with ascii
		return s:textline('', s:ascii(a:n))
	elseif a:n == 4 " filename
		return s:textline(s:filename(), s:ascii(a:n))
	elseif a:n == 6 " author
		return s:textline("By: " . s:user() . " <" . s:mail() . ">", s:ascii(a:n))
	elseif a:n == 8 " created
		return s:textline("Created: " . s:date() . " by " . s:user(), s:ascii(a:n))
	elseif a:n == 9 " created
		return s:textline("Updated: " . s:date() . " by " . s:user(), s:ascii(a:n))
	endif
endfunction

function! s:user()
	if exists('g:lpuser')
		return g:lpuser
	endif
	let l:user = $USER
	if strlen(l:user) == 0
		let l:user = "0xd34db33f"
	endif
	return l:user
endfunction

function! s:mail()
	if exists('g:lpmail')
		return g:lpmail
	endif
	let l:mail = $MAIL
	if strlen(l:mail) == 0
		let l:mail = l:user."@laplateforme.io"
	endif
	return l:mail
endfunction

function s:filename()
	let l:filename = expand("%:t")
	if strlen(l:filename) == 0
		let l:filename = "< new >"
	endif
	return l:filename
endfunction

function! s:date()
	return strftime("%Y/%m/%d %H:%M:%S")
endfunction

function! s:insert()
	let l:line = 11
	
	" empty line after header
	call append(0, "")

	" loop over lines
	while l:line > 0
		call append(0, s:line(l:line))
		let l:line = l:line - 1
	endwhile
endfunction

function! s:update()
	call s:filetype()
	set colorcolumn=s:length
	if getline(9) =~ s:start . repeat(' ', s:margin - strlen(s:start)) . "Updated: "
		if &mod
			call setline(9, s:line(9))
		endif
		call setline(4, s:line(4))
		return 0
	endif
	return 1
endfunction

function! s:header()
	if s:update()
		call s:insert()
	endif
endfunction

command! header call s:header ()
map <F1> :header<CR>
autocmd BufWritePre * call s:update ()
