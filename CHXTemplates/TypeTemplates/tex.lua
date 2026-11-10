-- Templates of LaTex for CHXTemplates micro editor plugin

-- Remember to set and use tabs as indetantion or "\t" if a simple string.
-- In micro use: setlocal tabstospaces false

local templates = {

------ Preamble

-- \newcommand
["nc"] = [[\newcommand{\\{{1:cmd}}}[{{2:opt}}]{{{3:realcmd}}} {{9}}]],

-- \usepackage
["up"] = [[\usepackage[{{1:options}}]{{{2:package}}} {{9}}]],

-- \newunicodechar
["nuc"] = [[\newunicodechar{{{1}}}{{{2:\ensuremath}}{{3:tex-substitute}}}} {{9}}]],

-- \DeclareMathOperator
["dmo"] = [[\DeclareMathOperator{{{1}}}{{{2}}} {{9}}]],

------ Document

-- \begin{}...\end{} block
["begin"] =
[[\begin{{{1:env}}}
  {{2:${VISUAL}}}
\end{{{1}}}
{{9}}
]],

-- Tabular (or arbitrary) environment
["tab"] =
[[\begin{{{1:tabular}}}{{{2:c}}}
	{{3:${VISUAL}}}
\end{{{1}}}
{{9}}
]],

-- thm (or arbitrary) environment with optional argument
["thm"] =
[[\begin[{{1:author}}]{{{2:thm}}}
	{{3:${VISUAL}}}
\end{{{2}}}
{{9}}
]],

-- Center environment
["center"] =
[[\begin{center}
	{{1:${VISUAL}}}
\end{center}
{{9}}
]],

-- Align(ed) environment
["ali"] =
[[\begin{align{{1:ed}}}
	\label{eq:{{2}}}
	{{3:${VISUAL}}}
\end{align{{1}}}
{{9}}
]],

-- Gather(ed) environment
["gat"] =
[[\begin{gather{{1:ed}}}
	{{2:${VISUAL}}}
\end{gather{{1}}}
{{9}}
]],

-- Equation environment
["eq"] =
[[\begin{equation}
	{{1:${VISUAL}}}
\end{equation}
{{9}}
]],

-- Labeled equation environment
["eql"] =
[[\begin{equation}
	\label{eq:{{1}}}
	{{2:${VISUAL}}}
\end{equation}
{{9}}
]],

-- Unnumbered equation environment
["equ"] =
[[\begin{equation*}
	{{1:${VISUAL}}}
\end{equation*}
{{9}}
]],

-- Unnumbered Equation \[ ... \]
["["] = [[
\[
	{{1:${VISUAL}}}
\]
{{9}}
]],

-- Equation array environment
["eqnarray"] =
[[\begin{eqnarray}
	{{1:${VISUAL}}}
\end{eqnarray}
{{9}}
]],

--  Label
["lab"] = "\label{{{1:eq:}}{{2:fig:}}{{3:tab:}}{{9}}}",

-- Enumerate environment
["enum"] =
[[\begin{enumerate}
	\item {{1}}
\end{enumerate}
{{9}}
]],

-- Enumerate environment (a)
["enuma"] =
[[\begin{enumerate}[(a)]
	\item {{1}}
\end{enumerate}
{{9}}
]],

-- Enumerate environment (i)
["enumi"] =
[[\begin{enumerate}[(i)]
	\item {{1}}
\end{enumerate}
{{9}}
]],

-- Itemize environment
["itemize"] =
[[\begin{itemize}
	\item {{1}}
\end{itemize}
{{9}}
]],

-- Item
["item"] =
[[\item {{1:${VISUAL}}}
{{9}}
]],

-- Description environment
["desc"] =
[[\begin{description}
	\item[{{1}}] {{2}}
\end{description}
{{9}}
]],

-- Endless new item (recursive)
["ir"] =
[[\item {{1}}
	{{1:]i}}
{{9}}
]],

-- Smart matrix environment
["mat"] =
[[\begin{{{1:p/b/v/V/B/small}}matrix}
	{{2:${VISUAL}}}
\end{{{1}}matrix}
{{9}}
]],

-- Cases enviroment
["cas"] =
[[\begin{cases}
	{{1:equation}}, &\text{ if }{{2:case}}\\
	{{3:${VISUAL}}}
\end{cases}
{{9}}
]],

-- Split environment
["spl"] =
[[\begin{split}
	{{1:${VISUAL}}}
\end{split}
{{9}}
]],

------ Document divisions

-- Part
["part"] =
[[\part{{{1:Name}}} % (fold)
\label{prt:{{2}}}
{{3}}
% part {{2}} (end)
{{9}}
]],

-- Chapter
["cha"] =
[[\chapter{{{1:Name}}}
\label{cha:{{1}}}
{{2}}
]],

-- Section
["sec"] =
[[\section{{{1:Name}}}
\label{sec:{{1}}}
{{2}}
]],

-- Section without number
["secu \section*"] =
[[\section*{{{1:Name}}}
\label{sec:{{1}}}
{{2}}
]],

-- Sub Section
["sub"] =
[[\subsection{{{1:Name}}}
\label{sub:{{1}}}
{{2}}
]],

-- Sub Section without number
["subu"] =
[[\subsection*{{{1:Name}}}
\label{sub:{{1}}}
{{2}}
]],

-- Sub Sub Section
["subs"] =
[[\subsubsection{{{1:Name}}}
\label{ssub:{{1}}}
{{2}}
]],

-- Sub Sub Section without number
["subsu"] =
[[\subsubsection*{{{1:Name}}}
\label{ssub:{{1}}}
{{2}}
]],

-- Paragraph
["par \paragraph"] =
[[\paragraph{{{1:Name}}}
\label{par:{{1}}}
{{2}}
]],

--  Subparagraph
["subp"] =
[[\subparagraph{{{1:Name}}}
\label{subp:{{1}}}
{{2}}
]],

-- No indent
["ni"] =
[[\noindent
{{1}}
]],

------ References

-- Description item
["itd"] = [[\item[{{1:Description}}] {{2:Item}}\n]],

-- Reference to a figure
["figure"] = [[{{1:Figure}}~\ref{{{2:fig:}}}]],

-- Reference to a table
["table"] = [[{{1:Table}}~\ref{{{2:tab:}}}]],

-- Reference to a listing
["listing"] = [[{{1:Listing}}~\ref{{{2:list}}}]],

-- Reference to a section
["section"] = [[{{1:Section}}~\ref{sec:{{2}}} {{3}}]],

-- Reference to a page
["page"] = [[{{1:page}}~\pageref{{{2}}} {{3}}]],

-- Index
["index"] = [[\index{{{1:index}}} {{3}}]],

------ Citations

["citen"] = [[\citen{{{1}}} {{2}}]],

-- natbib citations
["citep"] = [[\citep{{{1}}} {{2}}]],

["citet"] = [[\citet{{{1}}} {{2}}]],

["cite"] = [[\cite[{{1}}]{{{2}}} {{3}}]],

-- Cite author
["citea"] = [[\citeauthor{{{1}}} {{2}}]],

-- Cite year
["citey"] = [[\citeyear{{{1}}} {{2}}]],

-- Foot cite
["fcite"] = [[\footcite[{{1}}]{{{2}}}{{3}}]],

------ Formating text

-- Italic text
["it"] = [[\textit{{{1:${VISUAL:text}}}}]],

-- Bold face text
["bf"] = [[\textbf{{{1:${VISUAL:text}}}}]],

-- Underline text
["under"] = [[\underline{{{1:${VISUAL:text}}}}]],

-- Emphasize text
["emp"] = [[\emph{{{1:${VISUAL:text}}}}]],

-- Small caps text
["sc"] = [[\textsc{{{1:${VISUAL:text}}}}]],

------ Fonts

-- Sans serif text
["sf"] = [[\textsf{{{1:${VISUAL:text}}}}]],

-- Roman font text
["rm"] = [[\textrm{{{1:${VISUAL:text}}}}]],

-- Typewriter (monospace) text
["tt"] = [[\texttt{{{1:${VISUAL:text}}}}]],

------ Math fonts

-- Mathfrak
["mf"] = [[\mathfrak{{{1:${VISUAL:text}}}}]],

-- Mathcal
["mc"] = [[\mathcal{{{1:${VISUAL:text}}}}]],

-- Mathscr
["ms"] = [[\mathscr{{{1:${VISUAL:text}}}}]],

------ Miscellaneous

-- Footnote
["ft"] = [[\footnote{{{1:${VISUAL:text}}}}]],

-- Figure environment (includegraphics)
["fig"] =
[[\begin{figure}
	\begin{center}
		\includegraphics[scale={{1}}]{Figures/{{2}}}
	\end{center}
	\caption{{{3}}}
	\label{fig:{{4}}}
\end{figure}
{{5}}
]],

-- Figure environment (tikzpicture)
["tikz"] =
[[\begin{figure}
	\begin{center}
		\begin{tikzpicture}[scale={{1:1}}]
			{{2}}
		\end{tikzpicture}
	\end{center}
	\caption{{{3}}}
	\label{fig:{{4}}}
\end{figure}
{{5}}
]],

------ Math

-- Stackrel
["stackrel"] = [[\stackrel{{{1:above}}}{{{2:below}}} {{3}}]],

-- Fraction
["frac"] = [[\frac{{{1:num}}}{{{2:denom}}} {{3}}]],

-- Sum
["sum"] = [[\sum^{{{1:n}}}_{{{2:i=1}}} {{3}}]],

-- Lim
["lim"] = [[\lim_{{{1:n \to \infty}}} {{3}}]],

-- Frame environment
["frame"] =
[[\begin{frame}[{{1:t}}]{{{2:Title}}}
	{{3:${VISUAL}}}
\end{frame}
{{9}}
]],

-- Block environment
["block"] =
[[\begin{block}{{{1:Title}}}
	{{3:${VISUAL}}}
\end{block}
{{9}}
]],

-- Alertblock environment
["alert"] =
[[\begin{alertblock}{{{1:Title}}}
	{{3:${VISUAL}}}
\end{alertblock}
{{9}}
]],

-- Exampleblock environment
["example"] =
[[\begin{exampleblock}{{{1:Title}}}
	{{2:${VISUAL}}}
\end{exampleblock}
{{9}}
]],

-- Two columns environment
["col2"] =
[[\begin{columns}
	\begin{column}{0.5\textwidth}
		{{1}}
	\end{column}
	\begin{column}{0.5\textwidth}
		{{2}}
	\end{column}
\end{columns}
{{9}}
]],

-- Delimiters

-- Left Right
["lr"] = [[\left{{1}} {{2}} \right{{1}} {{9}}]],

-- { } (1)
["{"] = [[{ {{1}} } {{9}}]],

-- ( )
["("] = [[\left( {{1}} \right) {{9}}]],

-- | |
["|"] = [[\left| {{1}} \right| {{9}}]],

-- { } (2)
["brk"] = [[\left{ {{1}} \right} {{9}}]],

-- [ ]
["["] = "\\left[ {{1}} \\right] {{9}}",

-- < >
["lra"] = [[\langle {{1}} \rangle {{9}}]],

--  Code listings

["lst"] =
[[\begin{listing}[language={{1:language}}]
	{{2:${VISUAL}}}
\end{listing}
{{9}}
]],

["lsi"] = [[\lstinline|{{1}}| {{2}}]],

--  Hyperlinks

["url"] = [[\url{{{1}}} {{2}}]],

["href"] = [[\href{{{1}}}{{{2}}} {{3}}]],

}

return templates
